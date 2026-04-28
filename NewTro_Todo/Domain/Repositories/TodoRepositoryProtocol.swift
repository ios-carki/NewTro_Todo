import Foundation

protocol TodoRepositoryProtocol {
    @MainActor func fetchTodos(targetDate: Date) throws -> [TodoEntity]
    func fetchTodos(year: Int, month: Int) async throws -> [TodoEntity]
    func addTodo(text: String, emoji: String, importance: Importance, dueTime: Date?, targetDate: Date) async throws -> TodoEntity
    func updateText(id: String, text: String) async throws
    func updateTodo(id: String, text: String, emoji: String, importance: Importance, dueTime: Date?) async throws
    func toggleComplete(id: String) async throws
    func postpone(id: String, toDate: Date) async throws
    func updateImportance(id: String, importance: Importance) async throws
    func toggleFavorite(id: String) async throws
    func delete(id: String) async throws
    func deleteAll() async throws
}
