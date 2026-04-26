import SwiftUI

struct AchievementInfo: Identifiable {
    let id: String
    let name: String
    let description: String
    let sfSymbol: String
    let symbolColor: Color
}

enum AchievementData {
    static let all: [AchievementInfo] = [
        AchievementInfo(id: "first_todo",    name: "시작이 반",    description: "첫 번째 할일 완료",   sfSymbol: "star.fill",                 symbolColor: .sun),
        AchievementInfo(id: "streak_3",      name: "3연속",       description: "3일 연속 완료",       sfSymbol: "flame.fill",                symbolColor: .peach),
        AchievementInfo(id: "streak_7",      name: "일주일 전사", description: "7일 연속 완료",       sfSymbol: "bolt.fill",                 symbolColor: .sun),
        AchievementInfo(id: "perfect_day",   name: "퍼펙트",      description: "하루 모든 할일 완료", sfSymbol: "checkmark.seal.fill",       symbolColor: .done),
        AchievementInfo(id: "completed_100", name: "100 돌파",    description: "누적 100개 완료",     sfSymbol: "rosette",                   symbolColor: .pinkDk),
        AchievementInfo(id: "streak_30",     name: "한달 마스터", description: "30일 연속 완료",      sfSymbol: "calendar.badge.checkmark",  symbolColor: .grass),
        AchievementInfo(id: "streak_365",    name: "365챌린지",   description: "365일 연속 완료",     sfSymbol: "trophy.fill",               symbolColor: .sun),
        AchievementInfo(id: "all_complete",  name: "레전드",      description: "모든 업적 달성",      sfSymbol: "crown.fill",                symbolColor: Color(hex: "#9B30FF")),
    ]
}
