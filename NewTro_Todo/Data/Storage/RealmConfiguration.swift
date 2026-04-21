import Foundation
import RealmSwift

enum RealmConfiguration {
    // v1: 최초 앱 그룹 마이그레이션
    // v2: Todo.todo, QuickNote.note String? → String (required) 변경
    private static let schemaVersion: UInt64 = 2
    private static let appGroupIdentifier = "group.carki.NewTro_Todo"

    static var appGroupURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appendingPathComponent("default.realm")
    }

    static var configuration: Realm.Configuration {
        Realm.Configuration(
            fileURL: appGroupURL,
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

        Realm.Configuration.defaultConfiguration = configuration
    }

    private static let migrate: MigrationBlock = { migration, oldVersion in
        if oldVersion < 2 {
            // Todo.todo, QuickNote.note: String? → String
            // Realm이 nil 값을 "" 로 채우도록 enumerate
            migration.enumerateObjects(ofType: "Todo") { _, newObject in
                if newObject?["todo"] == nil {
                    newObject?["todo"] = ""
                }
            }
            migration.enumerateObjects(ofType: "QuickNote") { _, newObject in
                if newObject?["note"] == nil {
                    newObject?["note"] = ""
                }
            }
        }
    }
}
