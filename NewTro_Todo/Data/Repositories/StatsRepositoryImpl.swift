import Foundation

final class StatsRepositoryImpl: StatsRepositoryProtocol {

    private let defaults = UserDefaults.standard

    private enum Key {
        static let totalScore         = "stats_totalScore"
        static let currentStreak      = "stats_currentStreak"
        static let longestStreak      = "stats_longestStreak"
        static let totalCompleted     = "stats_totalCompleted"
        static let totalPerfectDays   = "stats_totalPerfectDays"
        static let lastActiveDate     = "stats_lastActiveDate"
        static let unlockedChars      = "stats_unlockedCharacters"
        static let earnedAchievs      = "stats_earnedAchievements"
        static let perfectDayDates    = "stats_perfectDayDateStrings"
        static let claimedChallenges  = "stats_claimedChallengeIds"
        static let dailyCheckDate     = "stats_dailyCheckDate"
        static let todayAddedTodo     = "stats_todayAddedTodo"
        static let todayPostponed     = "stats_todayPostponed"
        // 선택된 마스코트. stats 네임스페이스는 아니지만 캐릭터 보유/선택은 한 묶음이라 여기서 같이 백업.
        static let selectedCharacter  = "selectedCharacterId"
    }

    // MARK: - Fetch
    func fetchStats() async -> StatsEntity {
        refreshDailyIfNeeded()
        var unlocked = (defaults.array(forKey: Key.unlockedChars) as? [String]) ?? []
        if !unlocked.contains("pinko") { unlocked.insert("pinko", at: 0) }

        return StatsEntity(
            totalScore:           defaults.integer(forKey: Key.totalScore),
            currentStreak:        defaults.integer(forKey: Key.currentStreak),
            longestStreak:        defaults.integer(forKey: Key.longestStreak),
            totalCompleted:       defaults.integer(forKey: Key.totalCompleted),
            totalPerfectDays:     defaults.integer(forKey: Key.totalPerfectDays),
            lastActiveDate:       defaults.object(forKey: Key.lastActiveDate) as? Date,
            unlockedCharacterIds: unlocked,
            earnedAchievementIds: (defaults.array(forKey: Key.earnedAchievs)     as? [String]) ?? [],
            perfectDayDateStrings:(defaults.array(forKey: Key.perfectDayDates)   as? [String]) ?? [],
            claimedChallengeIds:  (defaults.array(forKey: Key.claimedChallenges) as? [String]) ?? [],
            todayAddedTodo:       defaults.bool(forKey: Key.todayAddedTodo),
            todayPostponed:       defaults.bool(forKey: Key.todayPostponed)
        )
    }

    // MARK: - Record Completion
    func recordCompletion(wasPostponed: Bool, isPerfectDay: Bool, date: Date) async {
        var score = defaults.integer(forKey: Key.totalScore)
        score += wasPostponed ? 10 : 15
        if isPerfectDay {
            score += 50
            defaults.set(defaults.integer(forKey: Key.totalPerfectDays) + 1, forKey: Key.totalPerfectDays)
            let dateStr = dayString(from: date)
            var perfectDates = (defaults.array(forKey: Key.perfectDayDates) as? [String]) ?? []
            if !perfectDates.contains(dateStr) {
                perfectDates.append(dateStr)
                defaults.set(perfectDates, forKey: Key.perfectDayDates)
            }
        }
        defaults.set(score, forKey: Key.totalScore)
        let total = defaults.integer(forKey: Key.totalCompleted) + 1
        defaults.set(total, forKey: Key.totalCompleted)

        let streak = updateStreak(date: date)
        let bonus = defaults.integer(forKey: Key.totalScore) + min(streak, 50)
        defaults.set(bonus, forKey: Key.totalScore)

        checkUnlocks()
        checkAchievements()
    }

    // MARK: - Record Todo Added
    func recordTodoAdded() async {
        refreshDailyIfNeeded()
        defaults.set(true, forKey: Key.todayAddedTodo)
    }

    // MARK: - Record Postpone
    func recordPostpone() async {
        refreshDailyIfNeeded()
        defaults.set(true, forKey: Key.todayPostponed)
    }

    // MARK: - Claim Challenge
    func claimChallenge(id: String, points: Int) async {
        var claimed = (defaults.array(forKey: Key.claimedChallenges) as? [String]) ?? []
        guard !claimed.contains(id) else { return }
        claimed.append(id)
        defaults.set(claimed, forKey: Key.claimedChallenges)
        let score = defaults.integer(forKey: Key.totalScore) + points
        defaults.set(score, forKey: Key.totalScore)
    }

    // MARK: - Reset
    func resetAll() async {
        [Key.totalScore, Key.currentStreak, Key.longestStreak, Key.totalCompleted,
         Key.totalPerfectDays, Key.lastActiveDate, Key.unlockedChars, Key.earnedAchievs,
         Key.perfectDayDates, Key.claimedChallenges,
         Key.dailyCheckDate, Key.todayAddedTodo, Key.todayPostponed]
            .forEach { defaults.removeObject(forKey: $0) }
    }

    // MARK: - Backup Snapshot

    func exportSnapshot() async -> BackupStatsRecord {
        var unlocked = (defaults.array(forKey: Key.unlockedChars) as? [String]) ?? []
        if !unlocked.contains("pinko") { unlocked.insert("pinko", at: 0) }

        return BackupStatsRecord(
            totalScore:            defaults.integer(forKey: Key.totalScore),
            currentStreak:         defaults.integer(forKey: Key.currentStreak),
            longestStreak:         defaults.integer(forKey: Key.longestStreak),
            totalCompleted:        defaults.integer(forKey: Key.totalCompleted),
            totalPerfectDays:      defaults.integer(forKey: Key.totalPerfectDays),
            lastActiveDate:        defaults.object(forKey: Key.lastActiveDate) as? Date,
            unlockedCharacterIds:  unlocked,
            earnedAchievementIds:  (defaults.array(forKey: Key.earnedAchievs)     as? [String]) ?? [],
            perfectDayDateStrings: (defaults.array(forKey: Key.perfectDayDates)   as? [String]) ?? [],
            claimedChallengeIds:   (defaults.array(forKey: Key.claimedChallenges) as? [String]) ?? [],
            selectedCharacterId:   defaults.string(forKey: Key.selectedCharacter)
        )
    }

    func restoreSnapshot(_ snapshot: BackupStatsRecord, mode: RestoreMode) async {
        switch mode {
        case .overwrite:
            defaults.set(snapshot.totalScore,             forKey: Key.totalScore)
            defaults.set(snapshot.currentStreak,          forKey: Key.currentStreak)
            defaults.set(snapshot.longestStreak,          forKey: Key.longestStreak)
            defaults.set(snapshot.totalCompleted,         forKey: Key.totalCompleted)
            defaults.set(snapshot.totalPerfectDays,       forKey: Key.totalPerfectDays)
            if let date = snapshot.lastActiveDate {
                defaults.set(date, forKey: Key.lastActiveDate)
            } else {
                defaults.removeObject(forKey: Key.lastActiveDate)
            }
            defaults.set(snapshot.unlockedCharacterIds,   forKey: Key.unlockedChars)
            defaults.set(snapshot.earnedAchievementIds,   forKey: Key.earnedAchievs)
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
            defaults.set(max(defaults.integer(forKey: Key.totalScore),       snapshot.totalScore),       forKey: Key.totalScore)
            defaults.set(max(defaults.integer(forKey: Key.currentStreak),    snapshot.currentStreak),    forKey: Key.currentStreak)
            defaults.set(max(defaults.integer(forKey: Key.longestStreak),    snapshot.longestStreak),    forKey: Key.longestStreak)
            defaults.set(max(defaults.integer(forKey: Key.totalCompleted),   snapshot.totalCompleted),   forKey: Key.totalCompleted)
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
            mergeUnion(key: Key.earnedAchievs,     into: snapshot.earnedAchievementIds)
            mergeUnion(key: Key.perfectDayDates,   into: snapshot.perfectDayDateStrings)
            mergeUnion(key: Key.claimedChallenges, into: snapshot.claimedChallengeIds)

            // 선택 마스코트는 백업 측 값이 있으면 우선 적용 (백업 의도 = A 상태 이식).
            // nil인 경우는 기존 B 선택 유지.
            if let selected = snapshot.selectedCharacterId {
                defaults.set(selected, forKey: Key.selectedCharacter)
            }
        }

        // 복구된 수치 기준으로 추가 잠금 해제·업적 조건이 새로 충족될 수 있음.
        checkUnlocks()
        checkAchievements()
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
        defaults.set(false, forKey: Key.todayPostponed)
    }

    @discardableResult
    private func updateStreak(date: Date) -> Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: date)
        let lastDate = defaults.object(forKey: Key.lastActiveDate) as? Date
        var streak = defaults.integer(forKey: Key.currentStreak)

        if let last = lastDate {
            let lastDay = cal.startOfDay(for: last)
            if cal.isDate(lastDay, inSameDayAs: today) {
                return streak
            } else if let yesterday = cal.date(byAdding: .day, value: -1, to: today),
                      cal.isDate(lastDay, inSameDayAs: yesterday) {
                streak += 1
            } else {
                streak = 1
            }
        } else {
            streak = 1
        }
        defaults.set(streak, forKey: Key.currentStreak)
        defaults.set(date, forKey: Key.lastActiveDate)
        defaults.set(max(defaults.integer(forKey: Key.longestStreak), streak), forKey: Key.longestStreak)
        return streak
    }

    private func checkUnlocks() {
        let total   = defaults.integer(forKey: Key.totalCompleted)
        let streak  = defaults.integer(forKey: Key.currentStreak)
        let perfect = defaults.integer(forKey: Key.totalPerfectDays)
        var unlocked = (defaults.array(forKey: Key.unlockedChars) as? [String]) ?? []

        let conditions: [(String, Bool)] = [
            ("bbiyak",    streak >= 3),
            ("minty",     total >= 10),
            ("bori",      streak >= 7),
            ("hwanggeum", perfect >= 3),
            ("blue",      total >= 30),
            ("lilac",     perfect >= 7),
            ("red",       streak >= 14),
            ("orange",    total >= 50),
            ("obsidian",  streak >= 21),
            ("snowflake", perfect >= 15),
            ("star",      total >= 100),
            ("cloud",     streak >= 30),
            ("flame",     perfect >= 30),
            ("water",     total >= 200),
            ("sprout",    streak >= 60),
            ("moon",      perfect >= 50),
            ("suncat",    total >= 365),
            ("rainbow",   streak >= 100),
        ]
        for (id, cond) in conditions {
            if cond && !unlocked.contains(id) { unlocked.append(id) }
        }
        if unlocked.filter({ $0 != "legend" }).count >= 19 && !unlocked.contains("legend") {
            unlocked.append("legend")
        }
        defaults.set(unlocked, forKey: Key.unlockedChars)
    }

    private func checkAchievements() {
        let total   = defaults.integer(forKey: Key.totalCompleted)
        let streak  = defaults.integer(forKey: Key.currentStreak)
        let perfect = defaults.integer(forKey: Key.totalPerfectDays)
        var earned  = (defaults.array(forKey: Key.earnedAchievs) as? [String]) ?? []

        let conditions: [(String, Bool)] = [
            ("first_todo",    total >= 1),
            ("streak_3",      streak >= 3),
            ("streak_7",      streak >= 7),
            ("perfect_day",   perfect >= 1),
            ("completed_100", total >= 100),
            ("streak_30",     streak >= 30),
            ("streak_365",    streak >= 365),
        ]
        for (id, cond) in conditions {
            if cond && !earned.contains(id) { earned.append(id) }
        }
        if earned.filter({ $0 != "all_complete" }).count >= 7 && !earned.contains("all_complete") {
            earned.append("all_complete")
        }
        defaults.set(earned, forKey: Key.earnedAchievs)
    }

    private func dayString(from date: Date) -> String {
        let cal = Calendar.current
        let y = cal.component(.year,  from: date)
        let m = cal.component(.month, from: date)
        let d = cal.component(.day,   from: date)
        return String(format: "%04d-%02d-%02d", y, m, d)
    }
}
