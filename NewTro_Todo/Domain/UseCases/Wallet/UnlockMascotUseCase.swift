import Foundation

protocol UnlockMascotUseCaseProtocol {
    func execute(mascotId: String, cost: Int) async throws
}

// 코인 결제로 마스코트를 해금. wallet.spend 가 선행되어 잔액 부족 시 throw,
// 잔액이 충분하면 차감 → stats.unlockCharacter 순서로 atomic 하게 진행.
// spend 가 실패하면 unlockCharacter 는 호출되지 않으므로 "차감되었는데 해금 안 됨" 상태 불가.
// 반대 방향(차감 성공 + UserDefaults set 실패)은 UserDefaults가 throw 하지 않으므로 사실상 불가.
final class UnlockMascotUseCase: UnlockMascotUseCaseProtocol {
    private let walletRepository: any WalletRepositoryProtocol
    private let statsRepository: any StatsRepositoryProtocol

    init(walletRepository: any WalletRepositoryProtocol,
         statsRepository: any StatsRepositoryProtocol) {
        self.walletRepository = walletRepository
        self.statsRepository = statsRepository
    }

    func execute(mascotId: String, cost: Int) async throws {
        try await walletRepository.spend(amount: cost)
        await statsRepository.unlockCharacter(id: mascotId)
    }
}
