import Foundation

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
            postponeCount: postponeCount,
            emoji: emoji,
            dueTime: dueTime,
            sortOrder: sortOrder,
            completedAt: completedAt
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
            postponeCount: postponeCount,
            emoji: emoji,
            dueTime: dueTime,
            sortOrder: sortOrder,
            completedAt: completedAt
        )
    }
}
