import Foundation

protocol AddTodoUseCaseProtocol {
    func execute(text: String, emoji: String, importance: Importance, dueTime: Date?, targetDate: Date) async throws -> TodoEntity
}

final class AddTodoUseCase: AddTodoUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(text: String, emoji: String, importance: Importance, dueTime: Date?, targetDate: Date) async throws -> TodoEntity {
        return try await repository.addTodo(text: text, emoji: emoji, importance: importance, dueTime: dueTime, targetDate: targetDate)
    }
}
