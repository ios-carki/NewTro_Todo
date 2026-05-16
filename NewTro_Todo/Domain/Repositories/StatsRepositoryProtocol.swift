import Foundation

protocol StatsRepositoryProtocol {
    func fetchStats() async -> StatsEntity
    func recordCompletion(wasPostponed: Bool, isPerfectDay: Bool, date: Date) async
    func recordTodoAdded() async
    func claimChallenge(id: String, points: Int) async
    func resetAll() async
    func exportSnapshot() async -> BackupStatsRecord
    func restoreSnapshot(_ snapshot: BackupStatsRecord, mode: RestoreMode) async
}
