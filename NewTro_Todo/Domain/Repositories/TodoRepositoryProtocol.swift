import Foundation

protocol TodoRepositoryProtocol {
    @MainActor func fetchTodos(targetDate: Date) throws -> [TodoEntity]
    func fetchTodos(year: Int, month: Int) async throws -> [TodoEntity]
    func addTodo(
        text: String,
        importance: Importance,
        targetDate: Date,
        targetTimeStart: Date?,
        targetTimeEnd: Date?,
        isAllDay: Bool,
        notifyAt: Date?,
        colorName: String
    ) async throws -> TodoEntity
    func updateText(id: String, text: String) async throws
    func updateTodo(
        id: String,
        text: String,
        importance: Importance,
        targetDate: Date,
        targetTimeStart: Date?,
        targetTimeEnd: Date?,
        isAllDay: Bool,
        notifyAt: Date?,
        colorName: String
    ) async throws
    func toggleComplete(id: String) async throws
    func updateImportance(id: String, importance: Importance) async throws
    func toggleFavorite(id: String) async throws
    func delete(id: String) async throws
    func deleteAll() async throws
    func updateSortOrders(updates: [(id: String, sortOrder: Int)]) async throws
    func fetchTodoCounts() async throws -> (completed: Int, total: Int)

    /// 통계 탭의 "미완료" 표기에 사용. targetDate < 오늘 (오늘/미래 제외) 이면서 isFinished == false 인 Todo 개수.
    /// 루틴이 미래로 미리 만들어둔 Todo 가 카운트에 섞이지 않도록 분리.
    func fetchPastIncompleteCount() async throws -> Int

    // MARK: - Routine support
    /// 루틴이 만든 Todo 를 idempotent 하게 추가. (routineId, targetDate) 중복 시 nil 반환.
    @MainActor func addTodoFromRoutine(
        routineId: String,
        targetDate: Date,
        text: String,
        importance: Importance,
        colorName: String
    ) throws -> TodoEntity?

    /// 다수의 날짜에 대해 한 번의 트랜잭션으로 루틴 Todo 를 idempotent 하게 추가.
    /// 매 날짜마다 별도 realm.write 를 여는 비용을 단일 트랜잭션 한 번으로 줄여,
    /// 12년치 점프 같은 대량 materialize 시 디스크 fsync 부하를 수천배 감소시킨다.
    /// 반환값: 실제로 추가된 개수 (중복 skip 분 제외).
    @MainActor func addTodosFromRoutine(
        routineId: String,
        dates: [Date],
        text: String,
        importance: Importance,
        colorName: String
    ) throws -> Int

    /// 해당 루틴이 만든 Todo 중 `from` (포함) 이후의 미완료 Todo 를 제거.
    @MainActor func deleteFutureIncompleteTodos(routineId: String, from: Date) throws
}
