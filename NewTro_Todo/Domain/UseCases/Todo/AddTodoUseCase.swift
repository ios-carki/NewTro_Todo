import Foundation

protocol AddTodoUseCaseProtocol {
    func execute(targetDate: Date) async throws -> TodoEntity
}

final class AddTodoUseCase: AddTodoUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(targetDate: Date) async throws -> TodoEntity {
        return try await repository.addTodo(targetDate: targetDate)
    }
}
