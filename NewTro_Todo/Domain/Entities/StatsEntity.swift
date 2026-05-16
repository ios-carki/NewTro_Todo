import Foundation

struct StatsEntity {
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
    var todayAddedTodo: Bool

    init(
        totalScore: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        totalCompleted: Int = 0,
        totalPerfectDays: Int = 0,
        lastActiveDate: Date? = nil,
        unlockedCharacterIds: [String] = [],
        earnedAchievementIds: [String] = [],
        perfectDayDateStrings: [String] = [],
        claimedChallengeIds: [String] = [],
        todayAddedTodo: Bool = false
    ) {
        self.totalScore = totalScore
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalCompleted = totalCompleted
        self.totalPerfectDays = totalPerfectDays
        self.lastActiveDate = lastActiveDate
        self.unlockedCharacterIds = unlockedCharacterIds
        self.earnedAchievementIds = earnedAchievementIds
        self.perfectDayDateStrings = perfectDayDateStrings
        self.claimedChallengeIds = claimedChallengeIds
        self.todayAddedTodo = todayAddedTodo
    }

    var level: Int { Int(sqrt(Double(totalScore) / 100.0)) }

    var nextLevelScore: Int {
        let next = level + 1
        return next * next * 100
    }

    var progressToNextLevel: Double {
        let cur = level
        let prevScore = cur * cur * 100
        let nextScore = (cur + 1) * (cur + 1) * 100
        guard nextScore > prevScore else { return 1.0 }
        return Double(totalScore - prevScore) / Double(nextScore - prevScore)
    }
}
