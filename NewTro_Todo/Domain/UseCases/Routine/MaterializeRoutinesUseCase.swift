import Foundation

protocol MaterializeRoutinesUseCaseProtocol {
    @MainActor func execute() throws
    @MainActor func execute(through: Date?) throws
    /// 동기 execute 와 동일하지만 청크 사이마다 `await Task.yield()` + `Task.checkCancellation()` 을 끼워넣어
    /// 메인스레드를 양보하고, 호출자가 만든 Task 를 cancel 하면 중도에 빠져나온다.
    /// 캘린더 월 nav 같이 빠른 연타가 일어나는 경로에서 사용.
    @MainActor func executeAsync(through: Date?) async throws
    @MainActor func reset()
    /// 지정 날짜까지 이미 materialize 가 완료된 상태인지 (in-memory 커서 기반, O(1)).
    /// UI 가 콜드 미스일 때만 로딩 표시/버튼 비활성화 결정하는 데 사용.
    @MainActor func isMaterialized(through: Date) -> Bool
}

// 앱 진입/포어그라운드/캘린더 월 이동 시 호출.
// 각 루틴에 대해 max(startDate, today) ~ min(endDate, targetHorizon) 사이의
// 매칭 날짜에 Todo 를 idempotent 하게 추가한다.
//
// targetHorizon = max(today+horizonDays, through ?? today+horizonDays)
//   - 콜드 스타트/포어그라운드: through nil → 기본 60일
//   - 캘린더 월 이동: through = endOfMonth → 그 달 끝까지 영구 캐시 확장
//
// 구현 핵심:
//   1) 청크 단위 (chunkDays) 로 끊어 처리. 청크마다 모든 루틴이 함께 처리됨 →
//      cursor 를 청크 경계로 안전하게 진보시킬 수 있음 (중도 cancel 안전).
//   2) 각 (루틴, 청크) 쌍에 대해 매칭 날짜를 미리 계산 → bulk repo 호출 → 단일 트랜잭션.
//      매 날짜마다 realm.write 를 여는 기존 방식 대비 디스크 fsync 가 수천배 감소.
//   3) executeAsync 는 청크 사이에 yield + cancellation 체크 → 메인스레드 비차단 + 즉각 취소.
//   4) executeAsync 는 horizon 을 cursor+5년 으로 cap. 사용자가 10년 뒤로 점프해도
//      한 번에 5년치까지만 만들고 종료. 다음 진입에서 이어서 채움.
final class MaterializeRoutinesUseCase: MaterializeRoutinesUseCaseProtocol {
    private let routineRepo: RoutineRepositoryProtocol
    private let todoRepo: TodoRepositoryProtocol
    private let horizonDays: Int

    /// 단일 청크 길이 (일). 트랜잭션 1회당 처리할 날짜 수.
    /// 청크가 너무 작으면 트랜잭션 횟수가 늘어나고, 너무 크면 yield 사이의 메인 점유가 길어짐.
    private let chunkDays: Int = 365

    /// executeAsync 가 한 번에 늘릴 수 있는 horizon 상한 (cursor + capYears).
    /// 콜드 스타트면 today + capYears 까지.
    private let capYears: Int = 5

    /// 이 인스턴스가 마지막으로 materialize 한 horizon. 동일/더 가까운 범위 요청 시 skip.
    /// 청크 완료마다 진보적으로 갱신되므로 중도 cancel 이 일어나도 완료된 부분은 캐시 유효.
    /// 루틴 추가/수정/삭제 직후엔 reset() 으로 무효화.
    private var materializedThrough: Date?

    init(
        routineRepo: RoutineRepositoryProtocol,
        todoRepo: TodoRepositoryProtocol,
        horizonDays: Int = 60
    ) {
        self.routineRepo = routineRepo
        self.todoRepo = todoRepo
        self.horizonDays = horizonDays
    }

    @MainActor
    func execute() throws {
        try execute(through: nil)
    }

    @MainActor
    func execute(through: Date?) throws {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard let horizon = computeHorizon(through: through, today: today, cal: cal, applyCap: false) else { return }
        if let cursor = materializedThrough, cursor >= horizon { return }

        let routines = try routineRepo.fetchAll()
        try runChunks(routines: routines, today: today, horizon: horizon, cal: cal) { _ in }
    }

    @MainActor
    func executeAsync(through: Date?) async throws {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard let horizon = computeHorizon(through: through, today: today, cal: cal, applyCap: true) else { return }
        if let cursor = materializedThrough, cursor >= horizon { return }

        let routines = try routineRepo.fetchAll()

        // 동기 청크 처리를 async wrapper 로 감쌀 수 없으므로 청크 루프를 직접 구성.
        let resumeFrom = materializedThrough ?? cal.date(byAdding: .day, value: -1, to: today) ?? today
        var chunkStart = nextDay(after: resumeFrom, cal: cal)
        if chunkStart < today { chunkStart = today }

        while chunkStart <= horizon {
            let chunkEnd = min(horizon, cal.date(byAdding: .day, value: chunkDays - 1, to: chunkStart) ?? chunkStart)
            try processChunk(routines: routines, chunkStart: chunkStart, chunkEnd: chunkEnd, cal: cal)
            // 청크 완료 → cursor 진보. 다음 청크 cancel 되어도 여기까지는 캐시 유효.
            materializedThrough = chunkEnd

            try Task.checkCancellation()
            await Task.yield()

            guard let nextStart = cal.date(byAdding: .day, value: 1, to: chunkEnd) else { break }
            chunkStart = nextStart
        }
    }

    /// 루틴 CRUD 후 호출. 다음 execute() 가 다시 풀스캔하도록.
    @MainActor
    func reset() {
        materializedThrough = nil
    }

    @MainActor
    func isMaterialized(through date: Date) -> Bool {
        guard let cursor = materializedThrough else { return false }
        return cursor >= Calendar.current.startOfDay(for: date)
    }

    // MARK: - Chunk pipeline

    @MainActor
    private func computeHorizon(through: Date?, today: Date, cal: Calendar, applyCap: Bool) -> Date? {
        guard let defaultHorizon = cal.date(byAdding: .day, value: horizonDays, to: today) else { return nil }
        let baseline = cal.startOfDay(for: defaultHorizon)
        let requested = through.map { cal.startOfDay(for: $0) } ?? baseline
        var horizon = max(baseline, requested)

        if applyCap {
            // cursor (없으면 today-1d) 기준 capYears 까지만 한 번에 늘림.
            let cursorBase = materializedThrough ?? cal.date(byAdding: .day, value: -1, to: today) ?? today
            if let cap = cal.date(byAdding: .year, value: capYears, to: cursorBase) {
                let cappedHorizon = cal.startOfDay(for: cap)
                // baseline 은 항상 보장 (콜드 스타트에서 60일은 무조건 처리).
                horizon = max(min(horizon, cappedHorizon), baseline)
            }
        }
        return horizon
    }

    /// 동기 청크 루프 (yield 없음). 호출되는 경우 horizon 이 보통 60일~월말 수준이라 청크 1~2개 만에 완료.
    @MainActor
    private func runChunks(
        routines: [RoutineEntity],
        today: Date,
        horizon: Date,
        cal: Calendar,
        between: (Date) throws -> Void
    ) throws {
        var chunkStart = nextDay(after: materializedThrough ?? cal.date(byAdding: .day, value: -1, to: today) ?? today, cal: cal)
        if chunkStart < today { chunkStart = today }

        while chunkStart <= horizon {
            let chunkEnd = min(horizon, cal.date(byAdding: .day, value: chunkDays - 1, to: chunkStart) ?? chunkStart)
            try processChunk(routines: routines, chunkStart: chunkStart, chunkEnd: chunkEnd, cal: cal)
            materializedThrough = chunkEnd
            try between(chunkEnd)
            guard let nextStart = cal.date(byAdding: .day, value: 1, to: chunkEnd) else { break }
            chunkStart = nextStart
        }
    }

    /// 한 청크 안에서 모든 루틴을 처리. 각 루틴마다 매칭 날짜를 모아 단일 트랜잭션으로 insert.
    @MainActor
    private func processChunk(
        routines: [RoutineEntity],
        chunkStart: Date,
        chunkEnd: Date,
        cal: Calendar
    ) throws {
        for routine in routines {
            let from = max(routine.startDate, chunkStart)
            let to   = min(routine.endDate, chunkEnd)
            guard from <= to else { continue }
            let dates = matchingDates(routine: routine, from: from, to: to, cal: cal)
            guard !dates.isEmpty else { continue }
            _ = try todoRepo.addTodosFromRoutine(
                routineId: routine.id,
                dates: dates,
                text: routine.title,
                importance: routine.importance,
                colorName: routine.colorName
            )
        }
    }

    @MainActor
    private func matchingDates(routine: RoutineEntity, from: Date, to: Date, cal: Calendar) -> [Date] {
        var result: [Date] = []
        var cursor = from
        while cursor <= to {
            if matches(routine, on: cursor) { result.append(cursor) }
            guard let next = cal.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result
    }

    @MainActor
    private func nextDay(after date: Date, cal: Calendar) -> Date {
        cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: date)) ?? date
    }

    // MARK: - Match rule

    @MainActor
    private func matches(_ routine: RoutineEntity, on date: Date) -> Bool {
        let cal = Calendar.current
        switch routine.repeatKind {
        case .daily:
            return true

        case .weekly:
            return routine.weekdays.contains(cal.component(.weekday, from: date))

        case .biweekly:
            guard routine.weekdays.contains(cal.component(.weekday, from: date)) else { return false }
            // startDate 의 주를 0주차로 두고 짝수 주차에만 매치.
            let weekDiff = weekDifference(from: routine.startDate, to: date, cal: cal)
            return weekDiff % 2 == 0

        case .monthly:
            let day = cal.component(.day, from: date)
            let lastDay = lastDayOfMonth(of: date, cal: cal)
            for slot in routine.monthDays {
                switch slot {
                case .day(let d):
                    // 해당 월에 day(d) 가 존재해야 매치 (예: 2/30 은 skip)
                    if d <= lastDay, d == day { return true }
                case .last:
                    if day == lastDay { return true }
                }
            }
            return false

        case .yearly:
            guard routine.yearMonth >= 1, routine.yearMonth <= 12,
                  cal.component(.month, from: date) == routine.yearMonth,
                  let slot = routine.yearDay else { return false }
            let day = cal.component(.day, from: date)
            let lastDay = lastDayOfMonth(of: date, cal: cal)
            switch slot {
            case .day(let d):
                return d <= lastDay && d == day
            case .last:
                return day == lastDay
            }
        }
    }

    // MARK: - Helpers

    @MainActor
    private func lastDayOfMonth(of date: Date, cal: Calendar) -> Int {
        cal.range(of: .day, in: .month, for: date)?.count ?? 28
    }

    @MainActor
    private func weekDifference(from base: Date, to date: Date, cal: Calendar) -> Int {
        let baseWeekStart = startOfWeek(of: base, cal: cal)
        let dateWeekStart = startOfWeek(of: date, cal: cal)
        let comps = cal.dateComponents([.weekOfYear], from: baseWeekStart, to: dateWeekStart)
        return abs(comps.weekOfYear ?? 0)
    }

    @MainActor
    private func startOfWeek(of date: Date, cal: Calendar) -> Date {
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return cal.date(from: comps) ?? date
    }
}
