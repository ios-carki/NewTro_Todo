import Foundation

// 백업 성공 시 1건씩 append 되는 로그 레코드.
// UserDefaults JSON 직렬화를 위해 Codable, 리스트 diff·ForEach 사용을 위해 Identifiable.
struct BackupLogEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let createdAt: Date
    let counts: BackupCounts

    init(id: UUID = UUID(), createdAt: Date = Date(), counts: BackupCounts) {
        self.id = id
        self.createdAt = createdAt
        self.counts = counts
    }
}

extension BackupCounts: Equatable {
    public static func == (lhs: BackupCounts, rhs: BackupCounts) -> Bool {
        lhs.todo == rhs.todo &&
        lhs.quickNote == rhs.quickNote &&
        lhs.template == rhs.template &&
        lhs.wallet == rhs.wallet &&
        lhs.postpone == rhs.postpone
    }
}
