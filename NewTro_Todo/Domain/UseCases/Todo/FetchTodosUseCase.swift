import Foundation

protocol FetchTodosUseCaseProtocol {
    @MainActor func execute(targetDate: Date) throws -> [TodoEntity]
}

final class FetchTodosUseCase: FetchTodosUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    @MainActor func execute(targetDate: Date) throws -> [TodoEntity] {
        return try repository.fetchTodos(targetDate: targetDate)
    }
}
