import Foundation
import RealmSwift

enum RealmConfiguration {
    // ── 스키마 버전 정책 ──
    // 실제 App Store 에 배포된 버전은 1.2.7(= schemaVersion 1) 뿐이다.
    // 리팩토링 과정에서 거쳐간 schemaVersion 2~15 는 한 번도 출시되지 않은 내부 단계라
    // 유지할 이유가 없어, 단일 마이그레이션(v1 → v2)으로 합쳤다.
    // (구 체인은 v1→v15 점프 시 이미 제거된 컬럼[postponeCount/emoji/dueTime]에 set 하다
    //  RLMDynamicValidatedSet NSException → abort 하는 버그가 있었음. 합치면서 함께 해소.)
    //
    // v1 (1.2.7 출시본):
    //   Todo{ todo:String?, favorite, importance:Int, regDate:Date, stringDate:String, isFinished }
    //   QuickNote{ note:String?, regDate:Date, stringToRegDate:String, isWrited }
    // v2 (현재): 위 데이터를 최종 스키마로 1회 변환 —
    //   - todo/note: String? → String(required) (nil → "")
    //   - targetDate(Date) 백필: stringDate/stringToRegDate("yyyy년 MM월 dd일") → startOfDay
    //   - sortOrder: regDate 음수 timestamp 로 최신순 보존
    //   - WalletObject 싱글톤 생성 + 완료 Todo·작성 메모 가중치로 코인 백필
    //   - 그 외 신규 컬럼(colorName 등)은 모델 기본값으로 Realm 이 자동 초기화
    //
    // ⚠️ schemaVersion 은 내릴 수 없다. 개발/테스트 중 이미 schemaVersion 15 로 올라간 기기는
    //    "version 2 is less than last set version 15" 로 Realm 을 못 연다 → 그 기기는 앱 삭제 후
    //    재설치 필요. (실제 유저는 전부 v1 이므로 영향 없음 — 테스트 데이터만 폐기됨)
    static let schemaVersion: UInt64 = 2
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

    // 1.2.7(v1) → 현재 스키마(v2)로의 단일 마이그레이션.
    // ⚠️ newObject 는 '최종 스키마'다. 최종 스키마에 없는 컬럼(postponeCount/emoji/dueTime 등)에는
    //    절대 set 하지 말 것 — RLMDynamicValidatedSet NSException 으로 앱이 죽는다.
    //    신규 컬럼은 대부분 모델 기본값으로 Realm 이 자동 초기화하므로, 변환이 필요한 것만 set 한다.
    private static let migrate: MigrationBlock = { migration, oldVersion in
        guard oldVersion < 2 else { return }

        // stringDate / stringToRegDate 백필 → targetDate.
        // 구 1.2.7 은 ko/en 두 언어만 지원했고 이 컬럼을 로케일별 포맷으로 저장했음:
        //   ko: "yyyy년 MM월 dd일"   /   en(및 그 외 모든 기기): "MMM dd YYYY" (예: "Mar 15 2024")
        // 두 포맷을 모두 시도해 '사용자가 지정한 날짜'를 보존하고, 다 실패하면 regDate(절대 시각) 폴백.
        let calendar = Calendar.current
        let koFormatter = DateFormatter()
        koFormatter.locale = Locale(identifier: "ko_KR")
        koFormatter.timeZone = .current
        koFormatter.dateFormat = "yyyy년 MM월 dd일"
        let enFormatter = DateFormatter()
        enFormatter.locale = Locale(identifier: "en_US_POSIX")
        enFormatter.timeZone = .current
        enFormatter.dateFormat = "MMM dd yyyy"
        func dayStart(from oldString: String?, regDate: Date?) -> Date {
            if let s = oldString, !s.isEmpty {
                if let d = koFormatter.date(from: s) { return calendar.startOfDay(for: d) }
                if let d = enFormatter.date(from: s) { return calendar.startOfDay(for: d) }
            }
            if let r = regDate { return calendar.startOfDay(for: r) }
            return calendar.startOfDay(for: Date())
        }

        // 코인 백필: 완료 Todo(중요도 가중치) + 작성된 QuickNote.
        // Importance.rawValue: none=0, high=1, medium=2 → 코인: 하/없음=1, 중=2, 상=3
        var totalEarned = 0

        migration.enumerateObjects(ofType: "Todo") { oldObject, newObject in
            // todo: String?(옵셔널) → String(필수). 옵셔널 여부가 바뀌면 Realm 이 값을
            // 자동 복사하지 않으므로(newObject 는 기본값 ""), oldObject 에서 직접 읽어 넣는다.
            newObject?["todo"] = (oldObject?["todo"] as? String) ?? ""
            // targetDate 백필
            newObject?["targetDate"] = dayStart(from: oldObject?["stringDate"] as? String,
                                                regDate: oldObject?["regDate"] as? Date)
            // 정렬 보존: 기존 Todo 를 최신순으로 (regDate 음수 timestamp)
            if let reg = oldObject?["regDate"] as? Date {
                newObject?["sortOrder"] = -Int(reg.timeIntervalSince1970)
            }
            // 코인 가중치 합산
            if let isFinished = oldObject?["isFinished"] as? Bool, isFinished {
                switch (oldObject?["importance"] as? Int) ?? 0 {
                case 1:  totalEarned += 3 // .high
                case 2:  totalEarned += 2 // .medium
                default: totalEarned += 1 // .none
                }
            }
            // colorName("yellow")·completedAt·notifyAt·targetTime*·routineId 등 나머지 신규 컬럼은
            // 모델 기본값으로 Realm 이 자동 초기화 → 별도 set 불필요.
        }

        migration.enumerateObjects(ofType: "QuickNote") { oldObject, newObject in
            // note: String?(옵셔널) → String(필수). Todo.todo 와 동일 — oldObject 에서 직접 복사.
            newObject?["note"] = (oldObject?["note"] as? String) ?? ""
            newObject?["targetDate"] = dayStart(from: oldObject?["stringToRegDate"] as? String,
                                                regDate: oldObject?["regDate"] as? Date)
            if let isWrited = oldObject?["isWrited"] as? Bool, isWrited { totalEarned += 1 }
        }

        // WalletObject(코인 지갑) 싱글톤 생성 — v1 엔 없던 신규 테이블.
        migration.create("WalletObject", value: [
            "id": "wallet",
            "balance": totalEarned,
            "totalEarned": totalEarned
        ])
    }
}
