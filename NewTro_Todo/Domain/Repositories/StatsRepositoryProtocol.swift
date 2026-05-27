import Foundation

protocol StatsRepositoryProtocol {
    func fetchStats() async -> StatsEntity
    func recordCompletion(wasPostponed: Bool, isPerfectDay: Bool, date: Date) async
    func recordTodoAdded() async
    func resetAll() async
    func exportSnapshot() async -> BackupStatsRecord
    func restoreSnapshot(_ snapshot: BackupStatsRecord, mode: RestoreMode) async
    // 코인 결제로 해금된 마스코트를 unlocked 목록에 추가. 이미 있으면 noop.
    // 통계 조건 기반 자동 해금(checkUnlocks)과 동일 저장소(Key.unlockedChars)를 사용.
    func unlockCharacter(id: String) async
}
