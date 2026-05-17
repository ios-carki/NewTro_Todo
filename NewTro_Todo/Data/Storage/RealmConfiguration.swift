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
    // v8: PostponeEventObject 신규 테이블, WalletObject 싱글톤 추가
    //     기존 완료 Todo·작성 메모를 가중치(.none=1, .medium=2, .high=3, 메모=1)로 합산 백필
    // v9: Todo.targetDate / QuickNote.targetDate Date 추가
    //     기존 stringDate / stringToRegDate(한국어 포맷) 파싱 → startOfDay 정규화해 백필
    //     실패 시 regDate.startOfDay fallback. stringDate 컬럼은 호환 위해 유지(롤백 안전망)
    // v10: 미루기 기능 제거 + 알림 모델 재설계
    //     Todo.dueTime → notifyAt 으로 lossless rename (baseline 알림 시각 보존)
    //     Todo에 targetTimeStart/targetTimeEnd/isAllDay 신규 컬럼 추가 (진행 시각 분리)
    //     기존 dueTime 값을 targetTimeStart에도 복사해 "진행 시각" 의미로도 보존
    //     PostponeEventObject 테이블 전체 삭제, Todo.postponeCount 컬럼 자동 drop
    // v11: 이모지 기능 제거 (기획 폐기)
    //     Todo.emoji / TemplateObject.emoji 컬럼은 모델 정의에서 사라져 Realm 이 자동 drop
    static let schemaVersion: UInt64 = 11
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
        // Importance.rawValue: none=0, high=1, medium=2 → 코인: 하/없음=1, 중=2, 상=3
        if oldVersion < 8 {
            var totalEarned = 0
            migration.enumerateObjects(ofType: "Todo") { _, newObject in
                guard let isFinished = newObject?["isFinished"] as? Bool, isFinished else { return }
                let importance = (newObject?["importance"] as? Int) ?? 0
                switch importance {
                case 1:  totalEarned += 3 // .high
                case 2:  totalEarned += 2 // .medium
                default: totalEarned += 1 // .none
                }
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
        // v9: targetDate Date 컬럼 백필
        // stringDate / stringToRegDate ("yyyy년 MM월 dd일") 파싱 → startOfDay 정규화
        // 파싱 실패 시 regDate.startOfDay fallback (데이터 손실 방지)
        if oldVersion < 9 {
            // 마이그 시점 헬퍼 변경에 영향받지 않도록 inline DateFormatter 구성
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.timeZone = .current
            formatter.dateFormat = "yyyy년 MM월 dd일"
            let calendar = Calendar.current

            func backfill(from oldString: String?, regDate: Date?) -> Date {
                if let s = oldString, !s.isEmpty, let parsed = formatter.date(from: s) {
                    return calendar.startOfDay(for: parsed)
                }
                if let r = regDate {
                    return calendar.startOfDay(for: r)
                }
                return calendar.startOfDay(for: Date())
            }

            migration.enumerateObjects(ofType: "Todo") { oldObject, newObject in
                let str = oldObject?["stringDate"] as? String
                let reg = oldObject?["regDate"] as? Date
                newObject?["targetDate"] = backfill(from: str, regDate: reg)
            }
            migration.enumerateObjects(ofType: "QuickNote") { oldObject, newObject in
                let str = oldObject?["stringToRegDate"] as? String
                let reg = oldObject?["regDate"] as? Date
                newObject?["targetDate"] = backfill(from: str, regDate: reg)
            }
        }
        // v10: 미루기 제거 + 알림 모델 재설계
        // dueTime → notifyAt 으로 rename (lossless). targetTimeStart 에도 같은 값 복사.
        // PostponeEventObject 테이블은 완전 삭제, postponeCount 컬럼은 모델 정의에서 사라져 자동 drop.
        if oldVersion < 10 {
            migration.renameProperty(onType: "Todo", from: "dueTime", to: "notifyAt")
            migration.enumerateObjects(ofType: "Todo") { _, newObject in
                newObject?["targetTimeStart"] = newObject?["notifyAt"]
                newObject?["targetTimeEnd"] = nil
                newObject?["isAllDay"] = false
            }
            migration.deleteData(forType: "PostponeEventObject")
        }
        // v11: 이모지 기능 제거. emoji 컬럼은 모델에서 사라져 자동 drop 됨.
    }
}
