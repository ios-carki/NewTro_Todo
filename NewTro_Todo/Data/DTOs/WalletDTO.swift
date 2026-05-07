import Foundation

extension WalletObject {
    func toDomain() -> WalletEntity {
        WalletEntity(balance: balance, totalEarned: totalEarned)
    }
}
