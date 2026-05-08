import Foundation
import RealmSwift

final class MemoRepositoryImpl: MemoRepositoryProtocol {

    func fetchAll() async throws -> [MemoEntity] {
        try await MainActor.run {
            let realm = try Realm()
            return realm.objects(QuickNote.self)
                .map { $0.toMemoEntity() }
                .sorted { $0.createdAt > $1.createdAt }
        }
    }

    func fetchMemos(from: Date, to: Date) async throws -> [MemoEntity] {
        try await MainActor.run {
            let realm = try Realm()
            return realm.objects(QuickNote.self)
                .filter("regDate >= %@ AND regDate < %@", from, to)
                .map { $0.toMemoEntity() }
                .sorted { $0.createdAt > $1.createdAt }
        }
    }

    func addMemo(colorName: String) async throws -> MemoEntity {
        try await MainActor.run {
            let realm = try Realm()
            let now = Date()
            let obj = QuickNote(
                note: "",
                regDate: now,
                stringToRegDate: "",
                targetDate: Calendar.current.startOfDay(for: now),
                isWrited: false,
                colorName: colorName
            )
            try realm.write { realm.add(obj) }
            return obj.toMemoEntity()
        }
    }

    func updateMemo(id: String, note: String, colorName: String) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let oid = try? ObjectId(string: id),
                  let obj = realm.object(ofType: QuickNote.self, forPrimaryKey: oid)
            else { throw RepositoryError.notFound }
            try realm.write {
                obj.note = note
                obj.colorName = colorName
                obj.isWrited = !note.isEmpty
            }
        }
    }

    func deleteMemo(id: String) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let oid = try? ObjectId(string: id),
                  let obj = realm.object(ofType: QuickNote.self, forPrimaryKey: oid)
            else { throw RepositoryError.notFound }
            try realm.write { realm.delete(obj) }
        }
    }

    func deleteAll() async throws {
        try await MainActor.run {
            let realm = try Realm()
            try realm.write { realm.delete(realm.objects(QuickNote.self)) }
        }
    }
}

private extension QuickNote {
    func toMemoEntity() -> MemoEntity {
        MemoEntity(
            id: objectID.stringValue,
            note: note,
            targetDate: regDate,
            colorName: colorName.isEmpty ? "yellow" : colorName,
            isWritten: isWrited,
            createdAt: regDate
        )
    }
}
