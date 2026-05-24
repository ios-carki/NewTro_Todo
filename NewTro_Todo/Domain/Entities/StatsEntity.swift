import Foundation

struct StatsEntity {
    var totalPerfectDays: Int
    var lastActiveDate: Date?
    var unlockedCharacterIds: [String]
    var perfectDayDateStrings: [String]
    var claimedChallengeIds: [String]
    var todayAddedTodo: Bool

    init(
        totalPerfectDays: Int = 0,
        lastActiveDate: Date? = nil,
        unlockedCharacterIds: [String] = [],
        perfectDayDateStrings: [String] = [],
        claimedChallengeIds: [String] = [],
        todayAddedTodo: Bool = false
    ) {
        self.totalPerfectDays = totalPerfectDays
        self.lastActiveDate = lastActiveDate
        self.unlockedCharacterIds = unlockedCharacterIds
        self.perfectDayDateStrings = perfectDayDateStrings
        self.claimedChallengeIds = claimedChallengeIds
        self.todayAddedTodo = todayAddedTodo
    }
}
