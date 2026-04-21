import Foundation

protocol FetchTodosUseCaseProtocol {
    func execute(targetDate: Date) async throws -> [TodoEntity]
}

final class FetchTodosUseCase: FetchTodosUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(targetDate: Date) async throws -> [TodoEntity] {
        return try await repository.fetchTodos(targetDate: targetDate)
    }
}
