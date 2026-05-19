import Foundation

enum CoinEarnReason {
    case todoCompleted

    var amount: Int {
        switch self {
        case .todoCompleted: return 1
        }
    }
}

protocol EarnCoinsUseCaseProtocol {
    func execute(reason: CoinEarnReason) async throws
    func revert(reason: CoinEarnReason) async throws
}

final class EarnCoinsUseCase: EarnCoinsUseCaseProtocol {
    private let repository: any WalletRepositoryProtocol
    init(repository: any WalletRepositoryProtocol) {
        self.repository = repository
    }
    func execute(reason: CoinEarnReason) async throws {
        try await repository.earn(amount: reason.amount)
    }
    func revert(reason: CoinEarnReason) async throws {
        try await repository.revertEarn(amount: reason.amount)
    }
}
