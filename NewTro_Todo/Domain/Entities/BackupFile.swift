import Foundation

// 백업 파일 전체 구조. Domain 계층이라 Foundation만 import.
// 각 Record는 Realm Object의 모든 필드를 1:1 보존하는 full-fidelity 데이터 타입.
struct BackupFile: Codable {
    let header: BackupHeader
    var todos: [BackupTodoRecord]
    var quickNotes: [BackupQuickNoteRecord]
    var templates: [BackupTemplateRecord]
    var wallet: BackupWalletRecord?
    // v10에서 미루기 기능 제거. 옛 백업 decode 호환을 위해 Optional 유지, 신규 export 시 nil.
    var postponeEvents: [BackupPostponeEventRecord]?
    // 이전 버전 백업 파일과의 호환을 위해 Optional. nil이면 stats를 건드리지 않음.
    var stats: BackupStatsRecord?
    // 백업 로그(이력) 자체도 다른 기기로 이어주기 위해 포함. nil이면 로그 건드리지 않음.
    var backupLogs: [BackupLogEntry]?
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
    // v10에서 미루기 기능 제거. 옛 백업 decode 호환을 위해 Optional 유지, 신규 export 시 nil.
    let postpone: Int?
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
    var emoji: String
    var sortOrder: Int
    var completedAt: Date?
    // v10 신규 4필드. 알림과 진행 시각이 분리됨.
    var targetTimeStart: Date?
    var targetTimeEnd: Date?
    var isAllDay: Bool?             // 옛 백업 decode 시 nil → false 해석
    var notifyAt: Date?
    // 옛 백업(v9 이하) decode 호환용. v10 export 시 항상 nil.
    var dueTime: Date?
    var postponeCount: Int?
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

// 캐릭터·업적·진척 수치를 백업/복구하기 위한 스냅샷.
// 일일 리셋 플래그(todayAddedTodo, todayPostponed, dailyCheckDate)는 디바이스 상태라 제외.
struct BackupStatsRecord: Codable, Equatable {
    var totalScore: Int
    var currentStreak: Int
    var longestStreak: Int
    var totalCompleted: Int
    var totalPerfectDays: Int
    var lastActiveDate: Date?
    var unlockedCharacterIds: [String]
    var earnedAchievementIds: [String]
    var perfectDayDateStrings: [String]
    var claimedChallengeIds: [String]
    // 백업 시점의 마스코트 선택. nil은 이전 버전 백업 호환용.
    var selectedCharacterId: String?
}
