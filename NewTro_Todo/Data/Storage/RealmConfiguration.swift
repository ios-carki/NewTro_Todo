import Foundation
import RealmSwift

enum RealmConfiguration {
    private static let schemaVersion: UInt64 = 1
    private static let appGroupIdentifier = "group.carki.NewTro_Todo"

    static var appGroupURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appendingPathComponent("default.realm")
    }

    static var configuration: Realm.Configuration {
        Realm.Configuration(
            fileURL: appGroupURL,
            schemaVersion: schemaVersion
        )
    }

    // AppDelegate에서 앱 시작 시 최초 1회 호출
    // 이전 버전(앱 그룹 미적용)의 Realm 파일을 앱 그룹 경로로 마이그레이션
    static func setup() {
        let legacyURL = Realm.Configuration.defaultConfiguration.fileURL

        if let legacyURL,
           let targetURL = appGroupURL,
           FileManager.default.fileExists(atPath: legacyURL.path) {
            try? FileManager.default.replaceItemAt(targetURL, withItemAt: legacyURL)
        }

        Realm.Configuration.defaultConfiguration = configuration
    }
}
