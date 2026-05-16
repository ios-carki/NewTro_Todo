import Foundation
import RealmSwift

// MARK: - Widget Data Models

struct WidgetTodoItem: Identifiable, Hashable {
    let id: String
    let text: String
    let emoji: String
    let importance: Int   // Importance.rawValue: 0=none, 1=high, 2=medium
    let done: Bool
    let targetTimeStart: Date?
    let targetTimeEnd: Date?
    let isAllDay: Bool
}

struct WidgetTodayData {
    let date: Date
    let total: Int
    let done: Int
    let topItems: [WidgetTodoItem]
    let coinBalance: Int

    var progress: Double {
        guard total > 0 else { return 0 }
        return Double(done) / Double(total)
    }

    static let placeholder = WidgetTodayData(
        date: Date(),
        total: 5,
        done: 2,
        topItems: [
            .init(id: "1", text: "운동 30분",   emoji: "💪", importance: 1, done: false, targetTimeStart: nil, targetTimeEnd: nil, isAllDay: false),
            .init(id: "2", text: "우유 사러 가기", emoji: "🥛", importance: 0, done: true,  targetTimeStart: nil, targetTimeEnd: nil, isAllDay: false),
            .init(id: "3", text: "도트 공부",   emoji: "🎮", importance: 2, done: false, targetTimeStart: nil, targetTimeEnd: nil, isAllDay: false),
            .init(id: "4", text: "책 한 챕터",  emoji: "📚", importance: 0, done: false, targetTimeStart: nil, targetTimeEnd: nil, isAllDay: false),
            .init(id: "5", text: "화분 물주기", emoji: "🌸", importance: 0, done: false, targetTimeStart: nil, targetTimeEnd: nil, isAllDay: false)
        ],
        coinBalance: 12
    )
}

// MARK: - Realm Reader (App Group 공유 Realm 읽기 전용)

enum WidgetRealmReader {
    static func loadToday(date: Date = Date(), limit: Int = 6) -> WidgetTodayData {
        let dayStart = Calendar.current.startOfDay(for: date)

        guard let realm = try? Realm(configuration: RealmConfiguration.configuration) else {
            return WidgetTodayData(date: dayStart, total: 0, done: 0, topItems: [], coinBalance: 0)
        }

        let todos = realm.objects(Todo.self)
            .filter("targetDate == %@", dayStart)
            .sorted(byKeyPath: "sortOrder", ascending: true)

        let total = todos.count
        let done = todos.filter("isFinished == true").count

        let items: [WidgetTodoItem] = todos.prefix(limit).map { t in
            WidgetTodoItem(
                id: t.objectID.stringValue,
                text: t.todo,
                emoji: t.emoji,
                importance: t.importance,
                done: t.isFinished,
                targetTimeStart: t.targetTimeStart,
                targetTimeEnd: t.targetTimeEnd,
                isAllDay: t.isAllDay
            )
        }

        let wallet = realm.object(ofType: WalletObject.self, forPrimaryKey: "wallet")
        let balance = wallet?.balance ?? 0

        return WidgetTodayData(
            date: dayStart,
            total: total,
            done: done,
            topItems: items,
            coinBalance: balance
        )
    }
}

// MARK: - Helpers

extension WidgetTodoItem {
    var priorityColor: PriorityColor {
        switch importance {
        case 1: return .high      // .high → red
        case 2: return .medium    // .medium → sun
        default: return .low      // .none → grass
        }
    }
}

enum PriorityColor {
    case high, medium, low
}
