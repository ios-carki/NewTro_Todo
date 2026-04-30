import Foundation

protocol UpdateTodoSortOrdersUseCaseProtocol {
    func execute(updates: [(id: String, sortOrder: Int)]) async throws
}

final class UpdateTodoSortOrdersUseCase: UpdateTodoSortOrdersUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(updates: [(id: String, sortOrder: Int)]) async throws {
        try await repository.updateSortOrders(updates: updates)
    }
}
