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

    // 완료 취소처럼 적립 자체를 "없던 일로" 되돌리는 케이스용.
    // 상점 소비(spend)와 달리 totalEarned 도 함께 감소시켜야 적립 이력 일관성이 유지됨.
    // 이미 소비해서 balance < amount 인 경우는 가능한 만큼만 차감 (음수 방지).
    func revertEarn(amount: Int) async throws {
        guard amount > 0 else { return }
        try await MainActor.run {
            let realm = try Realm()
            let wallet = ensureSingleton(in: realm)
            try realm.write {
                wallet.balance     = max(0, wallet.balance - amount)
                wallet.totalEarned = max(0, wallet.totalEarned - amount)
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
