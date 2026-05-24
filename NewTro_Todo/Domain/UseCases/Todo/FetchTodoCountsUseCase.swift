import Foundation

protocol FetchTodoCountsUseCaseProtocol {
    func execute() async throws -> (completed: Int, total: Int)
}

final class FetchTodoCountsUseCase: FetchTodoCountsUseCaseProtocol {
    private let repository: any TodoRepositoryProtocol

    init(repository: any TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> (completed: Int, total: Int) {
        try await repository.fetchTodoCounts()
    }
}
