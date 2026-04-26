import SwiftUI

enum ChallengeCategory {
    case daily
    case streak
    case cumulative

    var label: String {
        switch self {
        case .daily:      return "오늘의 도전"
        case .streak:     return "연속 도전"
        case .cumulative: return "누적 도전"
        }
    }
}

struct ChallengeDefinition: Identifiable {
    let challengeId: String
    let title: String
    let description: String
    let category: ChallengeCategory
    let sfSymbol: String
    let accentColor: Color
    let targetValue: Int
    let rewardPoints: Int
    let rewardCharacterId: String?
    let progressGetter: (StatsEntity) -> Int

    var id: String { challengeId }

    // For daily challenges, the claimed ID is date-scoped: "\(challengeId)_YYYY-MM-DD"
    func claimId(date: Date = Date()) -> String {
        if category == .daily {
            let cal = Calendar.current
            let y = cal.component(.year, from: date)
            let m = cal.component(.month, from: date)
            let d = cal.component(.day, from: date)
            return String(format: "%@_%04d-%02d-%02d", challengeId, y, m, d)
        }
        return challengeId
    }

    func isClaimed(stats: StatsEntity, date: Date = Date()) -> Bool {
        stats.claimedChallengeIds.contains(claimId(date: date))
    }

    func isCompleted(stats: StatsEntity) -> Bool {
        progressGetter(stats) >= targetValue
    }

    func progress(stats: StatsEntity) -> Int {
        min(progressGetter(stats), targetValue)
    }
}

enum ChallengeData {
    static let all: [ChallengeDefinition] = daily + streak + cumulative

    static let daily: [ChallengeDefinition] = [
        ChallengeDefinition(
            challengeId: "daily_addTodo",
            title: "할일 만들기",
            description: "오늘 할일을 1개 이상 작성해요",
            category: .daily,
            sfSymbol: "plus.circle.fill",
            accentColor: .grass,
            targetValue: 1,
            rewardPoints: 10,
            rewardCharacterId: nil,
            progressGetter: { $0.todayAddedTodo ? 1 : 0 }
        ),
        ChallengeDefinition(
            challengeId: "daily_perfect",
            title: "퍼펙트 클리어",
            description: "오늘 모든 할일을 완료해요",
            category: .daily,
            sfSymbol: "star.fill",
            accentColor: .sun,
            targetValue: 1,
            rewardPoints: 30,
            rewardCharacterId: nil,
            progressGetter: { stats in
                let today = {
                    let cal = Calendar.current
                    let y = cal.component(.year,  from: Date())
                    let m = cal.component(.month, from: Date())
                    let d = cal.component(.day,   from: Date())
                    return String(format: "%04d-%02d-%02d", y, m, d)
                }()
                return stats.perfectDayDateStrings.contains(today) ? 1 : 0
            }
        ),
        ChallengeDefinition(
            challengeId: "daily_noPostpone",
            title: "오늘 할 일은 오늘",
            description: "오늘은 미루지 않고 마무리해요",
            category: .daily,
            sfSymbol: "clock.badge.checkmark.fill",
            accentColor: .pixelPink,
            targetValue: 1,
            rewardPoints: 20,
            rewardCharacterId: nil,
            progressGetter: { stats in
                guard !stats.todayPostponed else { return 0 }
                let cal = Calendar.current
                let y = cal.component(.year,  from: Date())
                let m = cal.component(.month, from: Date())
                let d = cal.component(.day,   from: Date())
                let today = String(format: "%04d-%02d-%02d", y, m, d)
                return stats.perfectDayDateStrings.contains(today) ? 1 : 0
            }
        ),
    ]

    static let streak: [ChallengeDefinition] = [
        ChallengeDefinition(
            challengeId: "streak_3",
            title: "3일 연속",
            description: "3일 연속으로 할일을 완료해요",
            category: .streak, sfSymbol: "flame.fill", accentColor: .peach,
            targetValue: 3, rewardPoints: 50, rewardCharacterId: "bbiyak",
            progressGetter: { min($0.currentStreak, 3) }
        ),
        ChallengeDefinition(
            challengeId: "streak_7",
            title: "7일 연속",
            description: "7일 연속으로 할일을 완료해요",
            category: .streak, sfSymbol: "flame.fill", accentColor: .peach,
            targetValue: 7, rewardPoints: 100, rewardCharacterId: "bori",
            progressGetter: { min($0.currentStreak, 7) }
        ),
        ChallengeDefinition(
            challengeId: "streak_14",
            title: "2주 연속",
            description: "14일 연속으로 할일을 완료해요",
            category: .streak, sfSymbol: "bolt.fill", accentColor: .sun,
            targetValue: 14, rewardPoints: 150, rewardCharacterId: "red",
            progressGetter: { min($0.currentStreak, 14) }
        ),
        ChallengeDefinition(
            challengeId: "streak_30",
            title: "한달 연속",
            description: "30일 연속으로 할일을 완료해요",
            category: .streak, sfSymbol: "calendar.badge.checkmark", accentColor: .done,
            targetValue: 30, rewardPoints: 300, rewardCharacterId: "cloud",
            progressGetter: { min($0.currentStreak, 30) }
        ),
        ChallengeDefinition(
            challengeId: "streak_100",
            title: "100일 연속",
            description: "100일 연속 완주 — 전설의 시작",
            category: .streak, sfSymbol: "trophy.fill", accentColor: Color(hex: "#9B30FF"),
            targetValue: 100, rewardPoints: 1000, rewardCharacterId: "rainbow",
            progressGetter: { min($0.currentStreak, 100) }
        ),
    ]

    static let cumulative: [ChallengeDefinition] = [
        ChallengeDefinition(
            challengeId: "total_1",
            title: "첫 걸음",
            description: "할일을 처음으로 완료해요",
            category: .cumulative, sfSymbol: "star.fill", accentColor: .sun,
            targetValue: 1, rewardPoints: 15, rewardCharacterId: nil,
            progressGetter: { min($0.totalCompleted, 1) }
        ),
        ChallengeDefinition(
            challengeId: "total_10",
            title: "10개 달성",
            description: "할일을 누적 10개 완료해요",
            category: .cumulative, sfSymbol: "checkmark.circle.fill", accentColor: .done,
            targetValue: 10, rewardPoints: 50, rewardCharacterId: "minty",
            progressGetter: { min($0.totalCompleted, 10) }
        ),
        ChallengeDefinition(
            challengeId: "total_30",
            title: "30개 달성",
            description: "할일을 누적 30개 완료해요",
            category: .cumulative, sfSymbol: "checkmark.circle.fill", accentColor: .done,
            targetValue: 30, rewardPoints: 100, rewardCharacterId: "blue",
            progressGetter: { min($0.totalCompleted, 30) }
        ),
        ChallengeDefinition(
            challengeId: "total_50",
            title: "50개 달성",
            description: "할일을 누적 50개 완료해요",
            category: .cumulative, sfSymbol: "rosette", accentColor: .pinkDk,
            targetValue: 50, rewardPoints: 150, rewardCharacterId: "orange",
            progressGetter: { min($0.totalCompleted, 50) }
        ),
        ChallengeDefinition(
            challengeId: "total_100",
            title: "100개 달성",
            description: "할일을 누적 100개 완료해요",
            category: .cumulative, sfSymbol: "crown.fill", accentColor: Color(hex: "#9B30FF"),
            targetValue: 100, rewardPoints: 300, rewardCharacterId: "star",
            progressGetter: { min($0.totalCompleted, 100) }
        ),
        ChallengeDefinition(
            challengeId: "perfect_3",
            title: "퍼펙트 3회",
            description: "퍼펙트 데이를 3회 달성해요",
            category: .cumulative, sfSymbol: "star.circle.fill", accentColor: .sun,
            targetValue: 3, rewardPoints: 100, rewardCharacterId: "hwanggeum",
            progressGetter: { min($0.totalPerfectDays, 3) }
        ),
        ChallengeDefinition(
            challengeId: "perfect_7",
            title: "퍼펙트 7회",
            description: "퍼펙트 데이를 7회 달성해요",
            category: .cumulative, sfSymbol: "star.circle.fill", accentColor: .sun,
            targetValue: 7, rewardPoints: 200, rewardCharacterId: "lilac",
            progressGetter: { min($0.totalPerfectDays, 7) }
        ),
        ChallengeDefinition(
            challengeId: "perfect_15",
            title: "퍼펙트 15회",
            description: "퍼펙트 데이를 15회 달성해요",
            category: .cumulative, sfSymbol: "star.circle.fill", accentColor: .sun,
            targetValue: 15, rewardPoints: 400, rewardCharacterId: "snowflake",
            progressGetter: { min($0.totalPerfectDays, 15) }
        ),
    ]
}
