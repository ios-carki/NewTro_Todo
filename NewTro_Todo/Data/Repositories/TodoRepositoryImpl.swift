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

    func fetchTodos(targetDate: Date) async throws -> [TodoEntity] {
        try await MainActor.run {
            let realm = try Realm()
            let dateStr = DateFormatter.dateToString(date: targetDate)
            return realm.objects(Todo.self)
                .filter("stringDate == %@", dateStr)
                .sorted(byKeyPath: "regDate", ascending: true)
                .toArray()
                .map { $0.toDomain() }
        }
    }

    func addTodo(text: String, emoji: String, importance: Importance, dueTime: Date?, targetDate: Date) async throws -> TodoEntity {
        try await MainActor.run {
            let realm = try Realm()
            let todo = Todo(
                todo: text,
                favorite: false,
                importance: importance.rawValue,
                regDate: Date(),
                stringDate: DateFormatter.dateToString(date: targetDate),
                isFinished: false,
                emoji: emoji,
                dueTime: dueTime
            )
            try realm.write { realm.add(todo) }
            return todo.toDomain()
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
            try realm.write { todo.isFinished.toggle() }
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
}

private extension Results {
    func toArray() -> [Element] { Array(self) }
}
