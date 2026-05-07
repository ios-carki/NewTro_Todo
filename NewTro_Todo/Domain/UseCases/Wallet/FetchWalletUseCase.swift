import Foundation

protocol FetchWalletUseCaseProtocol {
    func execute() async throws -> WalletEntity
}

final class FetchWalletUseCase: FetchWalletUseCaseProtocol {
    private let repository: any WalletRepositoryProtocol
    init(repository: any WalletRepositoryProtocol) {
        self.repository = repository
    }
    func execute() async throws -> WalletEntity {
        try await repository.fetch()
    }
}
