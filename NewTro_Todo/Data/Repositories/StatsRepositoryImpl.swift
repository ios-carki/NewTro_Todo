import Foundation
import RealmSwift

final class StatsRepositoryImpl: StatsRepositoryProtocol {

    private let defaults = UserDefaults.standard

    private enum Key {
        static let totalPerfectDays   = "stats_totalPerfectDays"
        static let lastActiveDate     = "stats_lastActiveDate"
        static let unlockedChars      = "stats_unlockedCharacters"
        static let perfectDayDates    = "stats_perfectDayDateStrings"
        static let claimedChallenges  = "stats_claimedChallengeIds"
        static let dailyCheckDate     = "stats_dailyCheckDate"
        static let todayAddedTodo     = "stats_todayAddedTodo"
        // 선택된 마스코트. stats 네임스페이스는 아니지만 캐릭터 보유/선택은 한 묶음이라 여기서 같이 백업.
        static let selectedCharacter  = "selectedCharacterId"
    }

    // MARK: - Fetch
    func fetchStats() async -> StatsEntity {
        refreshDailyIfNeeded()
        var unlocked = (defaults.array(forKey: Key.unlockedChars) as? [String]) ?? []
        if !unlocked.contains("pinko") { unlocked.insert("pinko", at: 0) }

        return StatsEntity(
            totalPerfectDays:     defaults.integer(forKey: Key.totalPerfectDays),
            lastActiveDate:       defaults.object(forKey: Key.lastActiveDate) as? Date,
            unlockedCharacterIds: unlocked,
            perfectDayDateStrings:(defaults.array(forKey: Key.perfectDayDates)   as? [String]) ?? [],
            claimedChallengeIds:  (defaults.array(forKey: Key.claimedChallenges) as? [String]) ?? [],
            todayAddedTodo:       defaults.bool(forKey: Key.todayAddedTodo)
        )
    }

    // MARK: - Record Completion
    func recordCompletion(wasPostponed: Bool, isPerfectDay: Bool, date: Date) async {
        if isPerfectDay {
            defaults.set(defaults.integer(forKey: Key.totalPerfectDays) + 1, forKey: Key.totalPerfectDays)
            let dateStr = dayString(from: date)
            var perfectDates = (defaults.array(forKey: Key.perfectDayDates) as? [String]) ?? []
            if !perfectDates.contains(dateStr) {
                perfectDates.append(dateStr)
                defaults.set(perfectDates, forKey: Key.perfectDayDates)
            }
        }
        defaults.set(date, forKey: Key.lastActiveDate)
        await checkUnlocks()
    }

    // MARK: - Record Todo Added
    func recordTodoAdded() async {
        refreshDailyIfNeeded()
        defaults.set(true, forKey: Key.todayAddedTodo)
    }

    // MARK: - Reset
    func resetAll() async {
        // selectedCharacter도 함께 제거. 안 비우면 unlockedChars가 빈 상태에서
        // 선택값만 살아남아 "잠긴 캐릭터가 선택됨" 상태가 됨.
        [Key.totalPerfectDays, Key.lastActiveDate, Key.unlockedChars,
         Key.perfectDayDates, Key.claimedChallenges,
         Key.dailyCheckDate, Key.todayAddedTodo,
         Key.selectedCharacter]
            .forEach { defaults.removeObject(forKey: $0) }
    }

    // MARK: - Backup Snapshot

    func exportSnapshot() async -> BackupStatsRecord {
        var unlocked = (defaults.array(forKey: Key.unlockedChars) as? [String]) ?? []
        if !unlocked.contains("pinko") { unlocked.insert("pinko", at: 0) }

        return BackupStatsRecord(
            totalPerfectDays:      defaults.integer(forKey: Key.totalPerfectDays),
            lastActiveDate:        defaults.object(forKey: Key.lastActiveDate) as? Date,
            unlockedCharacterIds:  unlocked,
            perfectDayDateStrings: (defaults.array(forKey: Key.perfectDayDates)   as? [String]) ?? [],
            claimedChallengeIds:   (defaults.array(forKey: Key.claimedChallenges) as? [String]) ?? [],
            selectedCharacterId:   defaults.string(forKey: Key.selectedCharacter)
        )
    }

    func restoreSnapshot(_ snapshot: BackupStatsRecord, mode: RestoreMode) async {
        switch mode {
        case .overwrite:
            defaults.set(snapshot.totalPerfectDays,       forKey: Key.totalPerfectDays)
            if let date = snapshot.lastActiveDate {
                defaults.set(date, forKey: Key.lastActiveDate)
            } else {
                defaults.removeObject(forKey: Key.lastActiveDate)
            }
            defaults.set(snapshot.unlockedCharacterIds,   forKey: Key.unlockedChars)
            defaults.set(snapshot.perfectDayDateStrings,  forKey: Key.perfectDayDates)
            defaults.set(snapshot.claimedChallengeIds,    forKey: Key.claimedChallenges)

            // 선택 마스코트도 A 상태로. 이전 버전 백업(nil)이면 기본값 복귀를 위해 제거.
            if let selected = snapshot.selectedCharacterId {
                defaults.set(selected, forKey: Key.selectedCharacter)
            } else {
                defaults.removeObject(forKey: Key.selectedCharacter)
            }

        case .merge:
            // 수치는 max — 둘 중 더 진척된 값 채택.
            defaults.set(max(defaults.integer(forKey: Key.totalPerfectDays), snapshot.totalPerfectDays), forKey: Key.totalPerfectDays)

            // lastActiveDate는 더 최근 값.
            let currentLast = defaults.object(forKey: Key.lastActiveDate) as? Date
            let mergedLast: Date? = {
                switch (currentLast, snapshot.lastActiveDate) {
                case let (a?, b?): return max(a, b)
                case let (a?, nil): return a
                case let (nil, b?): return b
                case (nil, nil): return nil
                }
            }()
            if let date = mergedLast {
                defaults.set(date, forKey: Key.lastActiveDate)
            }

            // 집합은 합집합.
            mergeUnion(key: Key.unlockedChars,     into: snapshot.unlockedCharacterIds)
            mergeUnion(key: Key.perfectDayDates,   into: snapshot.perfectDayDateStrings)
            mergeUnion(key: Key.claimedChallenges, into: snapshot.claimedChallengeIds)

            // 선택 마스코트는 백업 측 값이 있으면 우선 적용 (백업 의도 = A 상태 이식).
            // nil인 경우는 기존 B 선택 유지.
            if let selected = snapshot.selectedCharacterId {
                defaults.set(selected, forKey: Key.selectedCharacter)
            }
        }

        // 복구된 수치 기준으로 추가 잠금 해제 조건이 새로 충족될 수 있음.
        await checkUnlocks()
    }

    private func mergeUnion(key: String, into incoming: [String]) {
        var existing = (defaults.array(forKey: key) as? [String]) ?? []
        var seen = Set(existing)
        for id in incoming where seen.insert(id).inserted {
            existing.append(id)
        }
        defaults.set(existing, forKey: key)
    }

    // MARK: - Private Helpers

    private func refreshDailyIfNeeded() {
        let today = dayString(from: Date())
        let last  = defaults.string(forKey: Key.dailyCheckDate) ?? ""
        guard today != last else { return }
        defaults.set(today, forKey: Key.dailyCheckDate)
        defaults.set(false, forKey: Key.todayAddedTodo)
    }

    private func checkUnlocks() async {
        let perfect = defaults.integer(forKey: Key.totalPerfectDays)
        let completed = await fetchCompletedTodoCount()
        var unlocked = (defaults.array(forKey: Key.unlockedChars) as? [String]) ?? []

        // v12 마스코트 해금 매핑: 완료 카운트 / 퍼펙트 데이 카운트 기준.
        // streak·점수 시스템이 사라지면서 streak/weekly perfect 기반 조건은 폐기.
        let conditions: [(String, Bool)] = [
            ("bbiyak",    completed >= 5),
            ("minty",     completed >= 10),
            ("bori",      completed >= 25),
            ("hwanggeum", perfect >= 3),
            ("blue",      completed >= 30),
            ("lilac",     perfect >= 7),
            ("red",       completed >= 75),
            ("orange",    completed >= 50),
            ("obsidian",  completed >= 150),
            ("snowflake", perfect >= 15),
            ("star",      completed >= 100),
            ("cloud",     completed >= 250),
            ("flame",     perfect >= 30),
            ("water",     completed >= 200),
            ("sprout",    completed >= 500),
            ("moon",      perfect >= 50),
            ("suncat",    completed >= 365),
            ("rainbow",   completed >= 1000),
            ("dawn",      perfect >= 1),
            ("leaf",      perfect >= 100),
            ("sunset",    perfect >= 200),
            ("galaxy",    perfect >= 500),
            ("chrono",    completed >= 2000),
        ]
        for (id, cond) in conditions {
            if cond && !unlocked.contains(id) { unlocked.append(id) }
        }
        if unlocked.filter({ $0 != "legend" }).count >= 24 && !unlocked.contains("legend") {
            unlocked.append("legend")
        }
        defaults.set(unlocked, forKey: Key.unlockedChars)
    }

    private func fetchCompletedTodoCount() async -> Int {
        // Realm I/O는 메인 스레드에서 처리. 통계 갱신은 frequent path가 아니라 비용 영향 적음.
        await MainActor.run {
            do {
                let realm = try Realm(configuration: RealmConfiguration.configuration)
                return realm.objects(Todo.self).filter("isFinished == true").count
            } catch {
                return 0
            }
        }
    }

    private func dayString(from date: Date) -> String {
        let cal = Calendar.current
        let y = cal.component(.year,  from: date)
        let m = cal.component(.month, from: date)
        let d = cal.component(.day,   from: date)
        return String(format: "%04d-%02d-%02d", y, m, d)
    }
}
