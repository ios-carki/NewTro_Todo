import Foundation
import RealmSwift
import XCTest
@testable import NewTro_Todo

/// 시간대 변경 견고성 회귀 테스트.
/// 다른 시간대의 자정으로 저장된 Todo 가 현재 시간대에선 같은 날 한낮(예: +16h) instant 로
/// 보이는 상황을 모사한다. 정확매칭(targetDate == 자정)이라면 빗나가 사라지거나 중복이 생기지만,
/// 범위 조회([그날 시작, 끝))로 바뀐 뒤에는 같은 로컬일로 올바르게 잡혀야 한다.
@MainActor
final class TodoRepositoryImplTimezoneTests: RealmTestCase {

    private var routineRepo: RoutineRepositoryImpl!
    private var todoRepo: TodoRepositoryImpl!

    private var todayStart: Date { Calendar.current.startOfDay(for: Date()) }

    /// 다른 시간대 자정이 현재 시간대에선 같은 날 +16h 로 보이는 instant.
    private var sameDayOtherTZInstant: Date {
        Calendar.current.date(byAdding: .hour, value: 16, to: todayStart) ?? todayStart
    }

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

    private func insertRawTodo(targetDate: Date, routineId: ObjectId? = nil) throws {
        let todo = Todo(
            todo: "x",
            favorite: false,
            importance: Importance.none.rawValue,
            regDate: Date(),
            stringDate: "",
            targetDate: targetDate,
            isFinished: false,
            colorName: "yellow",
            routineId: routineId
        )
        try realm.write { realm.add(todo) }
    }

    private func makeDailyRoutine() throws -> RoutineEntity {
        try routineRepo.add(
            RoutineFixture.daily(start: todayStart, end: TestDate.plus(days: 10, to: todayStart))
        )
    }

    // MARK: - T1: 그날 Todo 가 사라지지 않아야 함 (정확매칭 → 범위 조회)

    func test_fetchTodos_includes_todo_stored_at_other_timezone_midnight() throws {
        try insertRawTodo(targetDate: sameDayOtherTZInstant)

        let result = try todoRepo.fetchTodos(targetDate: todayStart)

        XCTAssertEqual(result.count, 1,
                       "다른 시간대 자정으로 저장된 Todo 도 같은 로컬일 조회에 포함돼야 한다")
    }

    // MARK: - T2: 루틴 단건 dedup 이 다른-tz 기존행과 충돌해야 함 (중복 방지)

    func test_addTodoFromRoutine_dedup_matches_other_timezone_existing() throws {
        let routine = try makeDailyRoutine()
        let rid = try ObjectId(string: routine.id)
        try insertRawTodo(targetDate: sameDayOtherTZInstant, routineId: rid)

        let created = try todoRepo.addTodoFromRoutine(
            routineId: routine.id,
            targetDate: todayStart,
            text: "x",
            importance: .none,
            colorName: "yellow"
        )

        XCTAssertNil(created, "같은 로컬일에 이미 루틴 Todo 가 있으면 중복 생성하지 않아야 한다")
        XCTAssertEqual(realm.objects(Todo.self).filter("routineId == %@", rid).count, 1)
    }

    // MARK: - T3: 루틴 벌크 dedup 이 다른-tz 기존행과 충돌해야 함 (중복 방지)

    func test_addTodosFromRoutine_dedup_matches_other_timezone_existing() throws {
        let routine = try makeDailyRoutine()
        let rid = try ObjectId(string: routine.id)
        try insertRawTodo(targetDate: sameDayOtherTZInstant, routineId: rid)

        let inserted = try todoRepo.addTodosFromRoutine(
            routineId: routine.id,
            dates: [todayStart],
            text: "x",
            importance: .none,
            colorName: "yellow"
        )

        XCTAssertEqual(inserted, 0, "다른 시간대 자정으로 저장된 기존 루틴 Todo 와 중복 생성하면 안 된다")
        XCTAssertEqual(realm.objects(Todo.self).filter("routineId == %@", rid).count, 1)
    }
}
