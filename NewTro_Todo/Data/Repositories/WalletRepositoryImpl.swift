import Foundation
import RealmSwift

final class WalletRepositoryImpl: WalletRepositoryProtocol {

    func fetch() async throws -> WalletEntity {
        try await MainActor.run {
            let realm = try Realm()
            let wallet = ensureSingleton(in: realm)
            return wallet.toDomain()
        }
    }

    func earn(amount: Int) async throws {
        guard amount > 0 else { return }
        try await MainActor.run {
            let realm = try Realm()
            let wallet = ensureSingleton(in: realm)
            try realm.write {
                wallet.balance += amount
                wallet.totalEarned += amount
            }
        }
    }

    func spend(amount: Int) async throws {
        guard amount > 0 else { return }
        try await MainActor.run {
            let realm = try Realm()
            let wallet = ensureSingleton(in: realm)
            guard wallet.balance >= amount else {
                throw RepositoryError.insufficientFunds
            }
            try realm.write {
                wallet.balance -= amount
            }
        }
    }

    private func ensureSingleton(in realm: Realm) -> WalletObject {
        if let existing = realm.object(ofType: WalletObject.self, forPrimaryKey: WalletObject.singletonId) {
            return existing
        }
        let new = WalletObject()
        try? realm.write { realm.add(new) }
        return new
    }
}
