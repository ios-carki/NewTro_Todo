import Foundation
import RealmSwift
import XCTest
@testable import NewTro_Todo

@MainActor
final class TodoRepositoryImplRoutineTests: RealmTestCase {

    private var routineRepo: RoutineRepositoryImpl!
    private var todoRepo: TodoRepositoryImpl!

    private var todayStart: Date { Calendar.current.startOfDay(for: Date()) }

    override func setUp() async throws {
        try await super.setUp()
        await MainActor.run {
            routineRepo = RoutineRepositoryImpl()
            todoRepo = TodoRepositoryImpl()
        }
    }

    override func tearDown() async throws {
        todoRepo = nil
        routineRepo = nil
        try await super.tearDown()
    }

    // MARK: - Helpers

    private func makeRoutine(title: String = "테스트 루틴") throws -> RoutineEntity {
        let start = todayStart
        let end = TestDate.plus(days: 10, to: start)
        return try routineRepo.add(RoutineFixture.daily(title: title, start: start, end: end))
    }

    private func todoCount(for routineId: String) -> Int {
        // swiftlint:disable:next force_try
        let oid = try! ObjectId(string: routineId)
        return realm.objects(Todo.self).filter("routineId == %@", oid).count
    }

    // MARK: - B1: Empty input

    func test_B1_addTodosFromRoutine_with_empty_dates_returns_zero() throws {
        let routine = try makeRoutine()
        let inserted = try todoRepo.addTodosFromRoutine(
            routineId: routine.id,
            dates: [],
            text: "x",
            importance: .none,
            colorName: "yellow"
        )
        XCTAssertEqual(inserted, 0)
        XCTAssertEqual(todoCount(for: routine.id), 0)
    }

    // MARK: - B2: Bulk insert produces N todos with expected properties

    func test_B2_bulk_insert_creates_one_todo_per_date() throws {
        let routine = try makeRoutine(title: "운동")
        let dates = (0..<7).map { TestDate.plus(days: $0, to: todayStart) }

        let inserted = try todoRepo.addTodosFromRoutine(
            routineId: routine.id,
            dates: dates,
            text: routine.title,
            importance: .high,
            colorName: "pink"
        )

        XCTAssertEqual(inserted, 7)
        XCTAssertEqual(todoCount(for: routine.id), 7)

        // swiftlint:disable:next force_try
        let oid = try! ObjectId(string: routine.id)
        let todos = realm.objects(Todo.self)
            .filter("routineId == %@", oid)
            .sorted(byKeyPath: "targetDate", ascending: true)
        for (i, todo) in todos.enumerated() {
            XCTAssertEqual(todo.targetDate, TestDate.plus(days: i, to: todayStart))
            XCTAssertEqual(todo.todo, "운동")
            XCTAssertEqual(todo.importance, Importance.high.rawValue)
            XCTAssertEqual(todo.colorName, "pink")
            XCTAssertFalse(todo.isFinished)
        }
    }

    // MARK: - B3: Input deduplication

    func test_B3_duplicate_dates_in_input_are_deduplicated() throws {
        let routine = try makeRoutine()
        let dup = todayStart
        let dates = [dup, dup, dup,
                     TestDate.plus(days: 1, to: dup),
                     TestDate.plus(days: 1, to: dup)]

        let inserted = try todoRepo.addTodosFromRoutine(
            routineId: routine.id,
            dates: dates,
            text: "x",
            importance: .none,
            colorName: "yellow"
        )

        XCTAssertEqual(inserted, 2)
        XCTAssertEqual(todoCount(for: routine.id), 2)
    }

    // MARK: - B4: Idempotent on full retry

    func test_B4_full_retry_inserts_nothing() throws {
        let routine = try makeRoutine()
        let dates = (0..<5).map { TestDate.plus(days: $0, to: todayStart) }

        _ = try todoRepo.addTodosFromRoutine(
            routineId: routine.id,
            dates: dates,
            text: "x",
            importance: .none,
            colorName: "yellow"
        )
        let secondInserted = try todoRepo.addTodosFromRoutine(
            routineId: routine.id,
            dates: dates,
            text: "x",
            importance: .none,
            colorName: "yellow"
        )

        XCTAssertEqual(secondInserted, 0)
        XCTAssertEqual(todoCount(for: routine.id), 5)
    }

    // MARK: - B5: Partial overlap inserts only new dates

    func test_B5_partial_overlap_inserts_only_new_dates() throws {
        let routine = try makeRoutine()
        let initial = (0..<3).map { TestDate.plus(days: $0, to: todayStart) }
        _ = try todoRepo.addTodosFromRoutine(
            routineId: routine.id,
            dates: initial,
            text: "x",
            importance: .none,
            colorName: "yellow"
        )

        // initial 과 [day3, day4] 가 합쳐진 입력
        let next = (1..<5).map { TestDate.plus(days: $0, to: todayStart) }
        let inserted = try todoRepo.addTodosFromRoutine(
            routineId: routine.id,
            dates: next,
            text: "x",
            importance: .none,
            colorName: "yellow"
        )

        XCTAssertEqual(inserted, 2)
        XCTAssertEqual(todoCount(for: routine.id), 5)
    }

    // MARK: - B6: Invalid ObjectId returns 0

    func test_B6_invalid_objectId_returns_zero() throws {
        let inserted = try todoRepo.addTodosFromRoutine(
            routineId: "not-a-real-objectId",
            dates: [todayStart],
            text: "x",
            importance: .none,
            colorName: "yellow"
        )
        XCTAssertEqual(inserted, 0)
        XCTAssertEqual(realm.objects(Todo.self).count, 0)
    }

    // MARK: - B7: Routine todo sortOrder is one less than manual todos on the same day

    func test_B7_routine_todo_sortOrder_is_below_existing_manual_todos() async throws {
        let routine = try makeRoutine()
        let day = todayStart

        // 1) 같은 날짜에 수동 Todo 를 먼저 추가 — sortOrder = 0 (min).
        _ = try await todoRepo.addTodo(
            text: "manual",
            importance: .none,
            targetDate: day,
            targetTimeStart: nil,
            targetTimeEnd: nil,
            isAllDay: false,
            notifyAt: nil,
            colorName: "yellow"
        )

        // 2) 그 다음 같은 날짜로 루틴 Todo 를 bulk 추가.
        let inserted = try todoRepo.addTodosFromRoutine(
            routineId: routine.id,
            dates: [day],
            text: "routine",
            importance: .none,
            colorName: "yellow"
        )
        XCTAssertEqual(inserted, 1)

        // swiftlint:disable:next force_try
        let oid = try! ObjectId(string: routine.id)
        let routineTodo = realm.objects(Todo.self)
            .filter("routineId == %@", oid)
            .first
        let manualTodo = realm.objects(Todo.self)
            .filter("routineId == nil AND targetDate == %@", day)
            .first

        guard let r = routineTodo, let m = manualTodo else {
            XCTFail("Both todos must exist"); return
        }
        XCTAssertLessThan(r.sortOrder, m.sortOrder,
                          "Routine todo sortOrder \(r.sortOrder) must be < manual \(m.sortOrder)")
    }

    // MARK: - B8: Non-startOfDay input normalized to startOfDay

    func test_B8_non_startOfDay_dates_are_normalized() throws {
        let routine = try makeRoutine()
        let cal = Calendar.current
        let noon = cal.date(byAdding: .hour, value: 13, to: todayStart) ?? todayStart
        let midnight = todayStart

        // 같은 날짜의 다른 시각 두 입력 → 한 번만 들어가야 함.
        let inserted = try todoRepo.addTodosFromRoutine(
            routineId: routine.id,
            dates: [noon, midnight],
            text: "x",
            importance: .none,
            colorName: "yellow"
        )
        XCTAssertEqual(inserted, 1)

        // swiftlint:disable:next force_try
        let oid = try! ObjectId(string: routine.id)
        let stored = realm.objects(Todo.self).filter("routineId == %@", oid).first
        XCTAssertEqual(stored?.targetDate, todayStart)
    }
}
