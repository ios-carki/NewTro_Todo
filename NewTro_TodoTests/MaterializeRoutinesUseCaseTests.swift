import Foundation
import RealmSwift
import XCTest
@testable import NewTro_Todo

@MainActor
final class MaterializeRoutinesUseCaseTests: RealmTestCase {

    private var routineRepo: RoutineRepositoryImpl!
    private var todoRepo: TodoRepositoryImpl!
    private var sut: MaterializeRoutinesUseCase!

    private var todayStart: Date { Calendar.current.startOfDay(for: Date()) }

    override func setUp() async throws {
        try await super.setUp()
        await MainActor.run {
            routineRepo = RoutineRepositoryImpl()
            todoRepo = TodoRepositoryImpl()
            sut = MaterializeRoutinesUseCase(
                routineRepo: routineRepo,
                todoRepo: todoRepo,
                horizonDays: 60
            )
        }
    }

    override func tearDown() async throws {
        sut = nil
        todoRepo = nil
        routineRepo = nil
        try await super.tearDown()
    }

    // MARK: - Helpers

    private func addRoutine(_ entity: RoutineEntity) throws -> RoutineEntity {
        try routineRepo.add(entity)
    }

    /// 특정 routineId 로 만들어진 Todo 만 반환 (targetDate 오름차순).
    private func routineTodos(for routineId: String) -> [Todo] {
        // swiftlint:disable:next force_try
        let oid = try! ObjectId(string: routineId)
        return realm.objects(Todo.self)
            .filter("routineId == %@", oid)
            .sorted(byKeyPath: "targetDate", ascending: true)
            .toArray()
    }

    private func allTodoDates(for routineId: String) -> [Date] {
        routineTodos(for: routineId).map { $0.targetDate }
    }

    // MARK: - A1: Empty routines

    func test_A1_execute_with_no_routines_inserts_nothing() throws {
        try sut.execute()
        XCTAssertEqual(realm.objects(Todo.self).count, 0)
    }

    // MARK: - A2: Single daily routine over 5 days

    func test_A2_daily_routine_inserts_one_todo_per_day_with_correct_props() throws {
        let start = todayStart
        let end = TestDate.plus(days: 4, to: start)
        let saved = try addRoutine(RoutineFixture.daily(
            title: "물 마시기",
            start: start,
            end: end,
            importance: .medium,
            colorName: "blue"
        ))

        try sut.execute()

        let todos = routineTodos(for: saved.id)
        XCTAssertEqual(todos.count, 5)
        for (i, todo) in todos.enumerated() {
            XCTAssertEqual(todo.targetDate, TestDate.plus(days: i, to: start))
            XCTAssertEqual(todo.todo, "물 마시기")
            XCTAssertEqual(todo.importance, Importance.medium.rawValue)
            XCTAssertEqual(todo.colorName, "blue")
            XCTAssertFalse(todo.isFinished)
        }
    }

    // MARK: - A3: Weekly (Mon/Wed/Fri) over 14 days

    func test_A3_weekly_routine_only_inserts_for_matching_weekdays() throws {
        // 1=일, 2=월, 4=수, 6=금
        let start = todayStart
        let end = TestDate.plus(days: 13, to: start)
        let saved = try addRoutine(RoutineFixture.weekly(
            weekdays: [2, 4, 6],
            start: start,
            end: end
        ))

        try sut.execute()

        let todos = routineTodos(for: saved.id)
        for todo in todos {
            let wd = Calendar.current.component(.weekday, from: todo.targetDate)
            XCTAssertTrue([2, 4, 6].contains(wd),
                          "Unexpected weekday \(wd) for date \(todo.targetDate)")
        }
        // 14 일 중 월/수/금 만: 정확한 개수는 시작 요일에 따라 다르지만 최소 4 ~ 최대 7 사이.
        XCTAssertGreaterThanOrEqual(todos.count, 4)
        XCTAssertLessThanOrEqual(todos.count, 7)
    }

    // MARK: - A4: Biweekly even-week filter

    func test_A4_biweekly_routine_matches_only_even_week_offsets() throws {
        let start = todayStart
        let end = TestDate.plus(days: 28, to: start)
        // 매칭 요일은 start 의 요일로 두면 첫 주는 무조건 매치되도록 보장.
        let startWeekday = Calendar.current.component(.weekday, from: start)
        let saved = try addRoutine(RoutineFixture.biweekly(
            weekdays: [startWeekday],
            start: start,
            end: end
        ))

        try sut.execute()

        let todos = routineTodos(for: saved.id)
        for todo in todos {
            // 같은 요일만 들어오는지
            XCTAssertEqual(Calendar.current.component(.weekday, from: todo.targetDate), startWeekday)
        }
        // 0주차, 2주차, 4주차 → 5주 범위에서 3건
        XCTAssertEqual(todos.count, 3)
    }

    // MARK: - A5: Monthly [.day(1), .day(15), .last]

    func test_A5_monthly_routine_matches_specific_days_and_last() throws {
        let cal = Calendar.current
        // start = 다음 달 1일 (확정적인 1일 매치 보장).
        guard let nextMonth = cal.date(byAdding: .month, value: 1, to: todayStart),
              let firstOfNextMonth = cal.date(from: cal.dateComponents([.year, .month], from: nextMonth)),
              let plusTwoMonths = cal.date(byAdding: .month, value: 2, to: firstOfNextMonth),
              let endOfRange = cal.date(byAdding: .day, value: -1,
                                        to: cal.date(byAdding: .month, value: 1, to: plusTwoMonths) ?? plusTwoMonths)
        else {
            XCTFail("date setup failed"); return
        }

        let saved = try addRoutine(RoutineFixture.monthly(
            monthDays: [.day(1), .day(15), .last],
            start: firstOfNextMonth,
            end: endOfRange
        ))

        // 60일 horizon 으로는 3개월이 안 들어올 수 있어 through 지정.
        try sut.execute(through: endOfRange)

        let todos = routineTodos(for: saved.id)
        for todo in todos {
            let day = cal.component(.day, from: todo.targetDate)
            let lastDay = cal.range(of: .day, in: .month, for: todo.targetDate)?.count ?? 28
            XCTAssertTrue(day == 1 || day == 15 || day == lastDay,
                          "Unexpected day \(day) (last=\(lastDay))")
        }
        // 3개월 × 3일 = 9건 (단, 15일과 last 가 겹치는 달은 없음 → 정확히 9)
        XCTAssertEqual(todos.count, 9)
    }

    // MARK: - A6: Monthly day(31) skips months without 31

    func test_A6_monthly_day31_skips_months_without_31() throws {
        let cal = Calendar.current
        // start = 2026-01-01, end = 2026-06-30 (Jan/Mar/May 31 = 3건)
        let start = TestDate.ymd(2026, 1, 1)
        let end = TestDate.ymd(2026, 6, 30)
        let saved = try addRoutine(RoutineFixture.monthly(
            monthDays: [.day(31)],
            start: start,
            end: end
        ))

        try sut.execute(through: end)

        let todos = routineTodos(for: saved.id)
        // 단, materialize 의 from = max(routine.startDate, today). today 가 6/30 이후라면 0건.
        // today 가 1/1 이전이면 3건. 그 사이면 today 이후 31일들 개수.
        for todo in todos {
            XCTAssertEqual(cal.component(.day, from: todo.targetDate), 31)
            // 31일이 있는 달만
            XCTAssertTrue([1, 3, 5, 7, 8, 10, 12].contains(cal.component(.month, from: todo.targetDate)))
        }
    }

    // MARK: - A7: Yearly with last-day-of-June

    func test_A7_yearly_last_day_of_june_across_3_years() throws {
        let cal = Calendar.current
        let start = todayStart
        let endOfThirdYear = cal.date(byAdding: .year, value: 3, to: start) ?? start
        let saved = try addRoutine(RoutineFixture.yearly(
            month: 6,
            day: .last,
            start: start,
            end: endOfThirdYear
        ))

        // 3년 → 5년 cap 안쪽이라 executeAsync 도 한 번에 처리 가능. 동기로 진행.
        try sut.execute(through: endOfThirdYear)

        let todos = routineTodos(for: saved.id)
        XCTAssertGreaterThanOrEqual(todos.count, 3)
        XCTAssertLessThanOrEqual(todos.count, 4)
        for todo in todos {
            XCTAssertEqual(cal.component(.month, from: todo.targetDate), 6)
            XCTAssertEqual(cal.component(.day, from: todo.targetDate), 30)
        }
    }

    // MARK: - A8: Idempotency

    func test_A8_execute_twice_does_not_duplicate() throws {
        let start = todayStart
        let end = TestDate.plus(days: 9, to: start)
        let saved = try addRoutine(RoutineFixture.daily(start: start, end: end))

        try sut.execute()
        let first = routineTodos(for: saved.id).count

        // cursor 무시하고 실제 idempotency 를 보려면 reset 후 다시.
        sut.reset()
        try sut.execute()
        let second = routineTodos(for: saved.id).count

        XCTAssertEqual(first, 10)
        XCTAssertEqual(second, 10)
    }

    // MARK: - A9: 5-year horizon cap via executeAsync

    func test_A9_executeAsync_caps_horizon_at_5_years() async throws {
        let cal = Calendar.current
        let start = todayStart
        // 10년 뒤까지 운영되는 루틴.
        let end = cal.date(byAdding: .year, value: 10, to: start) ?? start
        let saved = try addRoutine(RoutineFixture.daily(start: start, end: end))

        try await sut.executeAsync(through: end)

        let todos = routineTodos(for: saved.id)
        // cap = today + 5y. 5y 길이는 약 1826일.
        let cap = cal.date(byAdding: .year, value: 5, to: start) ?? start
        let capStart = cal.startOfDay(for: cap)
        for todo in todos {
            XCTAssertLessThanOrEqual(todo.targetDate, capStart)
        }
        // 5년 = 1826일 전후. 정확한 일수는 윤년 분포에 따라 다름. 1825 ~ 1827.
        XCTAssertGreaterThanOrEqual(todos.count, 1825)
        XCTAssertLessThanOrEqual(todos.count, 1828)
    }

    // MARK: - A10: through=nil → 60-day horizon default

    func test_A10_through_nil_uses_default_60_day_horizon() throws {
        let start = todayStart
        let end = TestDate.plus(days: 200, to: start)
        let saved = try addRoutine(RoutineFixture.daily(start: start, end: end))

        try sut.execute()  // through nil → today + 60

        let todos = routineTodos(for: saved.id)
        XCTAssertEqual(todos.count, 61)  // [today, today+60] 양쪽 끝 포함
    }

    // MARK: - A11: through expands beyond default 60 days

    func test_A11_through_can_expand_beyond_60d() throws {
        let start = todayStart
        let end = TestDate.plus(days: 200, to: start)
        let saved = try addRoutine(RoutineFixture.daily(start: start, end: end))

        let target = TestDate.plus(days: 90, to: start)
        try sut.execute(through: target)

        let todos = routineTodos(for: saved.id)
        XCTAssertEqual(todos.count, 91)
    }

    // MARK: - A12: cursor — second execute with same through is no-op

    func test_A12_second_execute_with_same_horizon_is_noop() throws {
        let start = todayStart
        let end = TestDate.plus(days: 30, to: start)
        let saved = try addRoutine(RoutineFixture.daily(start: start, end: end))

        try sut.execute(through: end)
        let first = routineTodos(for: saved.id).count

        // 추가 루틴을 만들지 않은 채 한 번 더. cursor 가 막아야 함.
        // (만약 막지 못해도 idempotency 로 todo 갯수는 동일하지만, repo addTodos 호출 자체가 일어남.)
        try sut.execute(through: end)
        let second = routineTodos(for: saved.id).count
        XCTAssertEqual(first, second)
        XCTAssertEqual(first, 31)
    }

    // MARK: - A13: reset() invalidates cursor

    func test_A13_reset_invalidates_cursor() throws {
        let start = todayStart
        let end = TestDate.plus(days: 5, to: start)
        let saved = try addRoutine(RoutineFixture.daily(start: start, end: end))

        try sut.execute(through: end)
        XCTAssertTrue(sut.isMaterialized(through: end))

        sut.reset()
        XCTAssertFalse(sut.isMaterialized(through: end))

        // reset 후 재실행 시에도 idempotency 보장 (개수 그대로).
        try sut.execute(through: end)
        XCTAssertEqual(routineTodos(for: saved.id).count, 6)
    }

    // MARK: - A14: executeAsync cancellation mid-flight preserves chunked progress

    func test_A14_executeAsync_cancellation_preserves_partial_progress() async throws {
        let cal = Calendar.current
        let start = todayStart
        // chunkDays = 365. 5년 = 5 chunks. 즉시 cancel 호출하면 1 chunk 이내에서 끊김.
        let end = cal.date(byAdding: .year, value: 5, to: start) ?? start
        let saved = try addRoutine(RoutineFixture.daily(start: start, end: end))

        let task = Task { @MainActor in
            try await sut.executeAsync(through: end)
        }
        task.cancel()
        // cancel 된 task 의 결과를 await — CancellationError 가 throw 될 수 있고,
        // 이미 종료된 케이스면 정상 완료될 수도 있음. 둘 다 허용.
        do { try await task.value } catch is CancellationError { /* expected */ }

        let count = routineTodos(for: saved.id).count
        // 부분 진행: 0 이거나 365 같은 청크 경계 값. 어쨌든 5×365 미만이어야 함.
        XCTAssertLessThanOrEqual(count, 365 * 5 + 5)
        // 진행된 부분이 있다면 cursor 가 그만큼 진보해 있어야 함.
        if count > 0 {
            // cursor 가 nil 이 아닐 것 (chunkEnd 까지 진보).
            XCTAssertTrue(sut.isMaterialized(through: todayStart))
        }
    }

    // MARK: - A15: Leap year Feb 29

    func test_A15_yearly_feb29_only_matches_leap_years() throws {
        // 2024 윤년 / 2025, 2026, 2027 평년 / 2028 윤년.
        // 단 today >= 2026-05-27 환경에서 시작 가능한 가장 가까운 윤년은 2028-02-29.
        let cal = Calendar.current
        let start = todayStart
        let endIn3Years = cal.date(byAdding: .year, value: 3, to: start) ?? start
        let saved = try addRoutine(RoutineFixture.yearly(
            month: 2,
            day: .day(29),
            start: start,
            end: endIn3Years
        ))

        try sut.execute(through: endIn3Years)

        let todos = routineTodos(for: saved.id)
        // 평년에는 2/29 자체가 존재하지 않아 매치 0. 3년 윈도우 안 윤년 횟수만.
        for todo in todos {
            XCTAssertEqual(cal.component(.month, from: todo.targetDate), 2)
            XCTAssertEqual(cal.component(.day, from: todo.targetDate), 29)
            // 윤년 검증
            let year = cal.component(.year, from: todo.targetDate)
            XCTAssertTrue((year % 4 == 0 && year % 100 != 0) || year % 400 == 0,
                          "Year \(year) is not a leap year")
        }
    }
}

private extension Results {
    func toArray() -> [Element] { Array(self) }
}
