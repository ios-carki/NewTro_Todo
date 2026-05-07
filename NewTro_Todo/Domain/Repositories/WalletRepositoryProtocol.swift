import Foundation

protocol WalletRepositoryProtocol {
    func fetch() async throws -> WalletEntity
    func earn(amount: Int) async throws
    func spend(amount: Int) async throws
}
