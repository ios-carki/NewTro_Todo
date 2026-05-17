import Foundation
import RealmSwift

final class TemplateRepositoryImpl: TemplateRepositoryProtocol {

    func fetchAll() async throws -> [TemplateEntity] {
        try await MainActor.run {
            let realm = try Realm()
            return realm.objects(TemplateObject.self)
                .map { $0.toEntity() }
                .sorted { $0.createdAt > $1.createdAt }
        }
    }

    func add(text: String, importance: Importance) async throws -> TemplateEntity {
        try await MainActor.run {
            let realm = try Realm()
            let obj = TemplateObject()
            obj.text = text
            obj.importance = importance.rawValue
            obj.createdAt = Date()
            try realm.write { realm.add(obj) }
            return obj.toEntity()
        }
    }

    func update(id: String, text: String, importance: Importance) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let obj = realm.object(ofType: TemplateObject.self, forPrimaryKey: id)
            else { throw RepositoryError.notFound }
            try realm.write {
                obj.text = text
                obj.importance = importance.rawValue
            }
        }
    }

    func delete(id: String) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let obj = realm.object(ofType: TemplateObject.self, forPrimaryKey: id)
            else { throw RepositoryError.notFound }
            try realm.write { realm.delete(obj) }
        }
    }
}

private extension TemplateObject {
    func toEntity() -> TemplateEntity {
        TemplateEntity(
            id: id,
            text: text,
            importance: Importance(rawValue: importance) ?? .none,
            createdAt: createdAt
        )
    }
}
