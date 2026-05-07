import Foundation

enum CoinEarnReason {
    case todoCompleted(importance: Importance)
    case memoCreated

    var amount: Int {
        switch self {
        case .todoCompleted(let importance): return importance.coinValue
        case .memoCreated:                    return 1
        }
    }
}

protocol EarnCoinsUseCaseProtocol {
    func execute(reason: CoinEarnReason) async throws
}

final class EarnCoinsUseCase: EarnCoinsUseCaseProtocol {
    private let repository: any WalletRepositoryProtocol
    init(repository: any WalletRepositoryProtocol) {
        self.repository = repository
    }
    func execute(reason: CoinEarnReason) async throws {
        try await repository.earn(amount: reason.amount)
    }
}
