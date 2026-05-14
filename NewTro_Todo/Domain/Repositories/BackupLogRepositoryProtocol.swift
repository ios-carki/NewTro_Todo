import Foundation

protocol BackupLogRepositoryProtocol {
    func append(_ entry: BackupLogEntry) async
    func fetchAll() async -> [BackupLogEntry]
    func clear() async
    func restoreSnapshot(_ entries: [BackupLogEntry], mode: RestoreMode) async
}
