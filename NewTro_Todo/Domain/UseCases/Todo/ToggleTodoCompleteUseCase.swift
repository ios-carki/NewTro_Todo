import Foundation

protocol ToggleTodoCompleteUseCaseProtocol {
    func execute(id: String) async throws
}

final class ToggleTodoCompleteUseCase: ToggleTodoCompleteUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String) async throws {
        try await repository.toggleComplete(id: id)
    }
}
