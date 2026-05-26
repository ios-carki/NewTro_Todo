import Foundation

enum RoutineRepeatKind: String, CaseIterable {
    case daily
    case weekly
    case biweekly
    case monthly
    case yearly
}

// 매월 / 매년 일자 선택용. 32 = 그 달의 마지막날.
// Realm 저장은 Int (1~31, 32) 로 한다.
enum RoutineDay: Equatable, Hashable {
    case day(Int)   // 1...31
    case last       // 그 달의 마지막날

    var rawValue: Int {
        switch self {
        case .day(let d): return d
        case .last: return 32
        }
    }

    init?(rawValue: Int) {
        if rawValue == 32 { self = .last }
        else if (1...31).contains(rawValue) { self = .day(rawValue) }
        else { return nil }
    }
}

struct RoutineEntity: Identifiable, Equatable {
    let id: String              // ObjectId.stringValue
    var title: String
    var startDate: Date         // startOfDay 정규화
    var endDate: Date           // startOfDay 정규화
    var repeatKind: RoutineRepeatKind

    // weekly / biweekly
    var weekdays: [Int]         // 1=일 ... 7=토

    // monthly
    var monthDays: [RoutineDay]

    // yearly
    var yearMonth: Int          // 1~12, 0 = 미설정
    var yearDay: RoutineDay?

    // 만들어지는 Todo 한 건 한 건에 그대로 적용될 값
    var importance: Importance
    var colorName: String

    var createdAt: Date
    var updatedAt: Date
}
