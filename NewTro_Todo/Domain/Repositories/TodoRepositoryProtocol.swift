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
        notifyAt: Date?
    ) async throws -> TodoEntity
    func updateText(id: String, text: String) async throws
    func updateTodo(
        id: String,
        text: String,
        importance: Importance,
        targetTimeStart: Date?,
        targetTimeEnd: Date?,
        isAllDay: Bool,
        notifyAt: Date?
    ) async throws
    func toggleComplete(id: String) async throws
    func updateImportance(id: String, importance: Importance) async throws
    func toggleFavorite(id: String) async throws
    func delete(id: String) async throws
    func deleteAll() async throws
    func updateSortOrders(updates: [(id: String, sortOrder: Int)]) async throws
}
