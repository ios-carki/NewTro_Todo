import Foundation
import RealmSwift

final class TodoRepositoryImpl: TodoRepositoryProtocol {

    func fetchTodos(year: Int, month: Int) async throws -> [TodoEntity] {
        try await MainActor.run {
            let realm = try Realm()
            // stringDate format: "yyyy년 MM월 dd일"
            let prefix = String(format: "%d년 %02d월", year, month)
            return realm.objects(Todo.self)
                .filter("stringDate BEGINSWITH %@", prefix)
                .toArray()
                .map { $0.toDomain() }
        }
    }

    @MainActor func fetchTodos(targetDate: Date) throws -> [TodoEntity] {
        let realm = try Realm()
        let dateStr = DateFormatter.dateToString(date: targetDate)
        let entities = realm.objects(Todo.self)
            .filter("stringDate == %@", dateStr)
            .toArray()
            .map { $0.toDomain() }
        return entities.sorted { a, b in
            if a.isCompleted != b.isCompleted { return !a.isCompleted }
            if !a.isCompleted { return a.sortOrder < b.sortOrder }
            return (a.completedAt ?? .distantPast) < (b.completedAt ?? .distantPast)
        }
    }

    func addTodo(text: String, emoji: String, importance: Importance, dueTime: Date?, targetDate: Date) async throws -> TodoEntity {
        try await MainActor.run {
            let realm = try Realm()
            let dateStr = DateFormatter.dateToString(date: targetDate)
            let minSortOrder: Int = realm.objects(Todo.self)
                .filter("stringDate == %@", dateStr)
                .min(ofProperty: "sortOrder") ?? 1
            let todo = Todo(
                todo: text,
                favorite: false,
                importance: importance.rawValue,
                regDate: Date(),
                stringDate: dateStr,
                isFinished: false,
                emoji: emoji,
                dueTime: dueTime,
                sortOrder: minSortOrder - 1
            )
            try realm.write { realm.add(todo) }
            return todo.toDomain()
        }
    }

    func updateTodo(id: String, text: String, emoji: String, importance: Importance, dueTime: Date?) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let todo = realm.objects(Todo.self)
                .filter("objectID == %@", try ObjectId(string: id)).first
            else { throw RepositoryError.notFound }
            try realm.write {
                todo.todo = text
                todo.emoji = emoji
                todo.importance = importance.rawValue
                todo.dueTime = dueTime
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

    func postpone(id: String, toDate: Date) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let todo = realm.objects(Todo.self)
                .filter("objectID == %@", try ObjectId(string: id)).first
            else { throw RepositoryError.notFound }
            try realm.write {
                todo.stringDate = DateFormatter.dateToString(date: toDate)
                todo.postponeCount += 1
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
}

private extension Results {
    func toArray() -> [Element] { Array(self) }
}
