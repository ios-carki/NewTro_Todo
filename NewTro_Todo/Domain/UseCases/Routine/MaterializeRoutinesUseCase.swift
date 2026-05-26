import Foundation

protocol MaterializeRoutinesUseCaseProtocol {
    @MainActor func execute() throws
}

// 앱 진입/포어그라운드 진입 시 호출.
// 각 루틴에 대해 max(startDate, today) ~ min(endDate, today+horizonDays) 사이의
// 매칭 날짜에 Todo 를 idempotent 하게 추가한다.
final class MaterializeRoutinesUseCase: MaterializeRoutinesUseCaseProtocol {
    private let routineRepo: RoutineRepositoryProtocol
    private let todoRepo: TodoRepositoryProtocol
    private let horizonDays: Int

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
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard let horizonEnd = cal.date(byAdding: .day, value: horizonDays, to: today) else { return }
        let horizon = cal.startOfDay(for: horizonEnd)

        let routines = try routineRepo.fetchAll()
        for routine in routines {
            let from = max(routine.startDate, today)
            let to   = min(routine.endDate, horizon)
            guard from <= to else { continue }

            var cursor = from
            while cursor <= to {
                if matches(routine, on: cursor) {
                    _ = try todoRepo.addTodoFromRoutine(
                        routineId: routine.id,
                        targetDate: cursor,
                        text: routine.title,
                        importance: routine.importance,
                        colorName: routine.colorName
                    )
                }
                guard let next = cal.date(byAdding: .day, value: 1, to: cursor) else { break }
                cursor = next
            }
        }
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
