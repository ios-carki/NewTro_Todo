import Foundation

protocol FetchIncompleteTodosUseCaseProtocol {
    func execute() async throws -> [TodoEntity]
}

final class FetchIncompleteTodosUseCase: FetchIncompleteTodosUseCaseProtocol {
    private let repository: any TodoRepositoryProtocol

    init(repository: any TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [TodoEntity] {
        try await repository.fetchIncompleteTodos()
    }
}
