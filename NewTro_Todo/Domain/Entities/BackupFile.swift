import Foundation

// 백업 파일 전체 구조. Domain 계층이라 Foundation만 import.
// 각 Record는 Realm Object의 모든 필드를 1:1 보존하는 full-fidelity 데이터 타입.
struct BackupFile: Codable {
    let header: BackupHeader
    var todos: [BackupTodoRecord]
    var quickNotes: [BackupQuickNoteRecord]
    var templates: [BackupTemplateRecord]
    var wallet: BackupWalletRecord?
    var postponeEvents: [BackupPostponeEventRecord]
}

struct BackupHeader: Codable {
    let appVersion: String
    let schemaVersion: Int
    let createdAt: Date
    let counts: BackupCounts
}

struct BackupCounts: Codable {
    let todo: Int
    let quickNote: Int
    let template: Int
    let wallet: Int
    let postpone: Int
}

struct BackupTodoRecord: Codable {
    let id: String                  // ObjectId.stringValue
    var todo: String
    var favorite: Bool
    var importance: Int
    var regDate: Date
    var stringDate: String
    var targetDate: Date
    var isFinished: Bool
    var postponeCount: Int
    var emoji: String
    var dueTime: Date?
    var sortOrder: Int
    var completedAt: Date?
}

struct BackupQuickNoteRecord: Codable {
    let id: String                  // ObjectId.stringValue
    var note: String
    var regDate: Date
    var stringToRegDate: String
    var targetDate: Date
    var isWrited: Bool
    var colorName: String
}

struct BackupTemplateRecord: Codable {
    let id: String                  // UUID string
    var text: String
    var emoji: String
    var importance: Int
    var createdAt: Date
}

struct BackupWalletRecord: Codable {
    let id: String                  // "wallet"
    var balance: Int
    var totalEarned: Int
}

struct BackupPostponeEventRecord: Codable {
    let id: String                  // UUID string
    var todoId: String              // Todo ObjectId.stringValue
    var eventDate: Date
    var ordinalAtTime: Int
}
