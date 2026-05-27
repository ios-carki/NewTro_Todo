import Foundation
import RealmSwift

extension Todo {
    func toDomain() -> TodoEntity {
        TodoEntity(
            id: objectID.stringValue,
            text: todo,
            isFavorite: favorite,
            importance: Importance(rawValue: importance) ?? .none,
            createdAt: regDate,
            targetDate: targetDate,
            isCompleted: isFinished,
            targetTimeStart: targetTimeStart,
            targetTimeEnd: targetTimeEnd,
            isAllDay: isAllDay,
            notifyAt: notifyAt,
            sortOrder: sortOrder,
            completedAt: completedAt,
            colorName: colorName,
            routineId: routineId?.stringValue
        )
    }
}

extension TodoEntity {
    func toRealmObject() -> Todo {
        let normalized = Calendar.current.startOfDay(for: targetDate)
        return Todo(
            todo: text,
            favorite: isFavorite,
            importance: importance.rawValue,
            regDate: createdAt,
            stringDate: DateFormatter.dateToString(date: normalized),
            targetDate: normalized,
            isFinished: isCompleted,
            targetTimeStart: targetTimeStart,
            targetTimeEnd: targetTimeEnd,
            isAllDay: isAllDay,
            notifyAt: notifyAt,
            sortOrder: sortOrder,
            completedAt: completedAt,
            colorName: colorName,
            routineId: routineId.flatMap { try? ObjectId(string: $0) }
        )
    }
}
