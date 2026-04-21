import Foundation

protocol ToggleTodoFavoriteUseCaseProtocol {
    func execute(id: String) async throws
}

final class ToggleTodoFavoriteUseCase: ToggleTodoFavoriteUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String) async throws {
        try await repository.toggleFavorite(id: id)
    }
}
