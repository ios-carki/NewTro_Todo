import Foundation

protocol EditTodoUseCaseProtocol {
    func execute(id: String, text: String, emoji: String, importance: Importance, dueTime: Date?) async throws
}

final class EditTodoUseCase: EditTodoUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String, text: String, emoji: String, importance: Importance, dueTime: Date?) async throws {
        try await repository.updateTodo(id: id, text: text, emoji: emoji, importance: importance, dueTime: dueTime)
    }
}
