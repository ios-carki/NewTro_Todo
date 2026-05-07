import Foundation

struct WalletEntity {
    var balance: Int
    var totalEarned: Int

    init(balance: Int = 0, totalEarned: Int = 0) {
        self.balance = balance
        self.totalEarned = totalEarned
    }
}
