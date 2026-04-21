import Foundation

protocol DeleteTodoUseCaseProtocol {
    func execute(id: String) async throws
}

final class DeleteTodoUseCase: DeleteTodoUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String) async throws {
        try await repository.delete(id: id)
    }
}
