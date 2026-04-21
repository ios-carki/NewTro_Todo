import Foundation

extension Todo {
    func toDomain() -> TodoEntity {
        TodoEntity(
            id: objectID.stringValue,
            text: todo,
            isFavorite: favorite,
            importance: Importance(rawValue: importance) ?? .none,
            createdAt: regDate,
            targetDate: DateFormatter.stringToDate(stringDate) ?? regDate,
            isCompleted: isFinished,
            postponeCount: postponeCount
        )
    }
}

extension TodoEntity {
    func toRealmObject() -> Todo {
        Todo(
            todo: text,
            favorite: isFavorite,
            importance: importance.rawValue,
            regDate: createdAt,
            stringDate: DateFormatter.dateToString(date: targetDate),
            isFinished: isCompleted,
            postponeCount: postponeCount
        )
    }
}
