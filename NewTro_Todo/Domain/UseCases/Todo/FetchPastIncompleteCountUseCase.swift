import Foundation

protocol FetchPastIncompleteCountUseCaseProtocol {
    func execute() async throws -> Int
}

final class FetchPastIncompleteCountUseCase: FetchPastIncompleteCountUseCaseProtocol {
    private let repository: any TodoRepositoryProtocol

    init(repository: any TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> Int {
        try await repository.fetchPastIncompleteCount()
    }
}
