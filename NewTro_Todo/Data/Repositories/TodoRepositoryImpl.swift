import Foundation
import RealmSwift

final class TodoRepositoryImpl: TodoRepositoryProtocol {

    func fetchTodos(year: Int, month: Int) async throws -> [TodoEntity] {
        try await MainActor.run {
            let realm = try Realm()
            let calendar = Calendar.current
            guard let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
                  let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: monthStart)
            else { return [] }
            return realm.objects(Todo.self)
                .filter("targetDate >= %@ AND targetDate < %@", monthStart, nextMonthStart)
                .toArray()
                .map { $0.toDomain() }
        }
    }

    @MainActor func fetchTodos(targetDate: Date) throws -> [TodoEntity] {
        let realm = try Realm()
        let dayStart = Calendar.current.startOfDay(for: targetDate)
        let entities = realm.objects(Todo.self)
            .filter("targetDate == %@", dayStart)
            .toArray()
            .map { $0.toDomain() }
        return entities.sorted { a, b in
            if a.isCompleted != b.isCompleted { return !a.isCompleted }
            if !a.isCompleted { return a.sortOrder < b.sortOrder }
            return (a.completedAt ?? .distantPast) < (b.completedAt ?? .distantPast)
        }
    }

    func addTodo(
        text: String,
        importance: Importance,
        targetDate: Date,
        targetTimeStart: Date?,
        targetTimeEnd: Date?,
        isAllDay: Bool,
        notifyAt: Date?,
        colorName: String
    ) async throws -> TodoEntity {
        try await MainActor.run {
            let realm = try Realm()
            let dayStart = Calendar.current.startOfDay(for: targetDate)
            let dateStr = DateFormatter.dateToString(date: dayStart)
            let minSortOrder: Int = realm.objects(Todo.self)
                .filter("targetDate == %@", dayStart)
                .min(ofProperty: "sortOrder") ?? 1
            let todo = Todo(
                todo: text,
                favorite: false,
                importance: importance.rawValue,
                regDate: Date(),
                stringDate: dateStr,
                targetDate: dayStart,
                isFinished: false,
                targetTimeStart: targetTimeStart,
                targetTimeEnd: targetTimeEnd,
                isAllDay: isAllDay,
                notifyAt: notifyAt,
                sortOrder: minSortOrder - 1,
                colorName: colorName
            )
            try realm.write { realm.add(todo) }
            return todo.toDomain()
        }
    }

    func updateTodo(
        id: String,
        text: String,
        importance: Importance,
        targetTimeStart: Date?,
        targetTimeEnd: Date?,
        isAllDay: Bool,
        notifyAt: Date?,
        colorName: String
    ) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let todo = realm.objects(Todo.self)
                .filter("objectID == %@", try ObjectId(string: id)).first
            else { throw RepositoryError.notFound }
            try realm.write {
                todo.todo = text
                todo.importance = importance.rawValue
                todo.targetTimeStart = targetTimeStart
                todo.targetTimeEnd = targetTimeEnd
                todo.isAllDay = isAllDay
                todo.notifyAt = notifyAt
                todo.colorName = colorName
            }
        }
    }

    func updateText(id: String, text: String) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let todo = realm.objects(Todo.self)
                .filter("objectID == %@", try ObjectId(string: id)).first
            else { throw RepositoryError.notFound }
            try realm.write { todo.todo = text }
        }
    }

    func toggleComplete(id: String) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let todo = realm.objects(Todo.self)
                .filter("objectID == %@", try ObjectId(string: id)).first
            else { throw RepositoryError.notFound }
            try realm.write {
                todo.isFinished.toggle()
                todo.completedAt = todo.isFinished ? Date() : nil
            }
        }
    }

    func updateImportance(id: String, importance: Importance) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let todo = realm.objects(Todo.self)
                .filter("objectID == %@", try ObjectId(string: id)).first
            else { throw RepositoryError.notFound }
            try realm.write { todo.importance = importance.rawValue }
        }
    }

    func toggleFavorite(id: String) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let todo = realm.objects(Todo.self)
                .filter("objectID == %@", try ObjectId(string: id)).first
            else { throw RepositoryError.notFound }
            try realm.write { todo.favorite.toggle() }
        }
    }

    func delete(id: String) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let todo = realm.objects(Todo.self)
                .filter("objectID == %@", try ObjectId(string: id)).first
            else { throw RepositoryError.notFound }
            try realm.write { realm.delete(todo) }
        }
    }

    func deleteAll() async throws {
        try await MainActor.run {
            let realm = try Realm()
            try realm.write {
                realm.delete(realm.objects(Todo.self))
            }
        }
    }

    func updateSortOrders(updates: [(id: String, sortOrder: Int)]) async throws {
        try await MainActor.run {
            let realm = try Realm()
            let pairs = try updates.map { (try ObjectId(string: $0.id), $0.sortOrder) }
            try realm.write {
                for (oid, order) in pairs {
                    if let todo = realm.objects(Todo.self).filter("objectID == %@", oid).first {
                        todo.sortOrder = order
                    }
                }
            }
        }
    }

    func fetchTodoCounts() async throws -> (completed: Int, total: Int) {
        try await MainActor.run {
            let realm = try Realm()
            let all = realm.objects(Todo.self)
            return (all.filter("isFinished == true").count, all.count)
        }
    }

    func fetchIncompleteTodos() async throws -> [TodoEntity] {
        try await MainActor.run {
            let realm = try Realm()
            return realm.objects(Todo.self)
                .filter("isFinished == false")
                .toArray()
                .map { $0.toDomain() }
        }
    }
}

private extension Results {
    func toArray() -> [Element] { Array(self) }
}
