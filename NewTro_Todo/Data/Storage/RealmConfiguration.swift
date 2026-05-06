import Foundation
import RealmSwift

enum RealmConfiguration {
    // v1: 최초 앱 그룹 마이그레이션
    // v2: Todo.todo, QuickNote.note String? → String (required) 변경
    // v3: Todo.postponeCount Int 추가 (기본값 0)
    // v4: QuickNote.colorName String 추가 (기본값 "yellow")
    // v5: Todo.emoji String 추가 (기본값 ""), Todo.dueTime Date? 추가 (기본값 nil)
    // v6: TemplateObject 신규 테이블 추가
    // v7: Todo.sortOrder Int 추가 (regDate 기반 역순 초기값), Todo.completedAt Date? 추가
    // v8: PostponeEventObject 신규 테이블, WalletObject 싱글톤 추가 (기존 완료 Todo+메모 가중치 합산 백필)
    static let schemaVersion: UInt64 = 8
    private static let appGroupIdentifier = "group.carki.NewTro_Todo"

    static var appGroupURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appendingPathComponent("default.realm")
    }

    static var configuration: Realm.Configuration {
        let fileURL = appGroupURL ?? Realm.Configuration.defaultConfiguration.fileURL
        return Realm.Configuration(
            fileURL: fileURL,
            schemaVersion: schemaVersion,
            migrationBlock: migrate
        )
    }

    // AppDelegate에서 앱 시작 시 최초 1회 호출
    static func setup() {
        let legacyURL = Realm.Configuration.defaultConfiguration.fileURL

        if let legacyURL,
           let targetURL = appGroupURL,
           FileManager.default.fileExists(atPath: legacyURL.path) {
            try? FileManager.default.replaceItemAt(targetURL, withItemAt: legacyURL)
        }

        // 새 schemaVersion 첫 실행 시 마이그레이션 직전 백업 (사용자 데이터 보존 안전망).
        // 백업 파일이 이미 있으면 건너뛰어 한 번만 실행됨.
        backupIfNeeded()

        Realm.Configuration.defaultConfiguration = configuration
    }

    private static func backupIfNeeded() {
        guard let realmURL = appGroupURL,
              FileManager.default.fileExists(atPath: realmURL.path) else { return }
        let backupURL = realmURL
            .deletingLastPathComponent()
            .appendingPathComponent("default.realm.backup-v\(schemaVersion)")
        guard !FileManager.default.fileExists(atPath: backupURL.path) else { return }
        try? FileManager.default.copyItem(at: realmURL, to: backupURL)
    }

    private static let migrate: MigrationBlock = { migration, oldVersion in
        if oldVersion < 2 {
            migration.enumerateObjects(ofType: "Todo") { _, newObject in
                if newObject?["todo"] == nil { newObject?["todo"] = "" }
            }
            migration.enumerateObjects(ofType: "QuickNote") { _, newObject in
                if newObject?["note"] == nil { newObject?["note"] = "" }
            }
        }
        if oldVersion < 3 {
            migration.enumerateObjects(ofType: "Todo") { _, newObject in
                newObject?["postponeCount"] = 0
            }
        }
        if oldVersion < 4 {
            migration.enumerateObjects(ofType: "QuickNote") { _, newObject in
                newObject?["colorName"] = "yellow"
            }
        }
        if oldVersion < 5 {
            migration.enumerateObjects(ofType: "Todo") { _, newObject in
                newObject?["emoji"] = ""
                newObject?["dueTime"] = nil
            }
        }
        // v6: TemplateObject is a new table — no existing data to migrate
        if oldVersion < 7 {
            migration.enumerateObjects(ofType: "Todo") { oldObject, newObject in
                // sortOrder: 기존 Todo를 newest-first로 정렬하기 위해 regDate의 음수 timestamp 사용
                if let regDate = oldObject?["regDate"] as? Date {
                    newObject?["sortOrder"] = -Int(regDate.timeIntervalSince1970)
                } else {
                    newObject?["sortOrder"] = 0
                }
                newObject?["completedAt"] = nil
            }
        }
        // v8: WalletObject 싱글톤 생성 — 기존 완료 Todo + 작성된 QuickNote 가중치 합산해 백필
        if oldVersion < 8 {
            var totalEarned = 0
            migration.enumerateObjects(ofType: "Todo") { _, newObject in
                guard let isFinished = newObject?["isFinished"] as? Bool, isFinished else { return }
                let importance = (newObject?["importance"] as? Int) ?? 0
                let favorite = (newObject?["favorite"] as? Bool) ?? false
                totalEarned += (importance != 0 || favorite) ? 2 : 1
            }
            migration.enumerateObjects(ofType: "QuickNote") { _, newObject in
                guard let isWrited = newObject?["isWrited"] as? Bool, isWrited else { return }
                totalEarned += 1
            }
            migration.create("WalletObject", value: [
                "id": "wallet",
                "balance": totalEarned,
                "totalEarned": totalEarned
            ])
        }
    }
}
