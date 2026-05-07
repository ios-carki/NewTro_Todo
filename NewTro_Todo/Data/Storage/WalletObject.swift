import Foundation
import RealmSwift

final class WalletObject: Object {
    @Persisted(primaryKey: true) var id: String = WalletObject.singletonId
    @Persisted var balance: Int = 0
    @Persisted var totalEarned: Int = 0

    static let singletonId = "wallet"
}
