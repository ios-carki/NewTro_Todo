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

    // MARK: - Routine support
    /// 루틴이 만든 Todo 를 idempotent 하게 추가. (routineId, targetDate) 중복 시 nil 반환.
    @MainActor func addTodoFromRoutine(
        routineId: String,
        targetDate: Date,
        text: String,
        importance: Importance,
        colorName: String
    ) throws -> TodoEntity?

    /// 해당 루틴이 만든 Todo 중 `from` (포함) 이후의 미완료 Todo 를 제거.
    @MainActor func deleteFutureIncompleteTodos(routineId: String, from: Date) throws
}
