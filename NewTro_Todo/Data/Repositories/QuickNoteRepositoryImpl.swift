import Foundation
import RealmSwift

final class QuickNoteRepositoryImpl: QuickNoteRepositoryProtocol {

    func fetchOrCreate(targetDate: Date) async throws -> QuickNoteEntity {
        try await MainActor.run {
            let realm = try Realm()
            let dayStart = Calendar.current.startOfDay(for: targetDate)
            // 시간대 변경 후에도 그날 메모 슬롯이 사라지지 않도록 정확매칭 대신 [시작, 끝) 범위 조회.
            let range = dayStart.dayRange

            if let existing = realm.objects(QuickNote.self)
                .filter("targetDate >= %@ AND targetDate < %@", range.start, range.end).first {
                return existing.toDomain()
            }

            // stringToRegDate는 v10 제거 예정. 그 전까지 호환 위해 함께 기록.
            let dateStr = DateFormatter.dateToString(date: dayStart)
            let newNote = QuickNote(
                note: "",
                regDate: targetDate,
                stringToRegDate: dateStr,
                targetDate: dayStart,
                isWrited: false
            )
            try realm.write { realm.add(newNote) }
            return newNote.toDomain()
        }
    }

    func updateNote(id: String, note: String) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let quickNote = realm.objects(QuickNote.self)
                .filter("objectID == %@", try ObjectId(string: id)).first
            else { throw RepositoryError.notFound }
            try realm.write {
                quickNote.note = note
                quickNote.isWrited = !note.isEmpty
            }
        }
    }

    func deleteAll() async throws {
        try await MainActor.run {
            let realm = try Realm()
            try realm.write {
                realm.delete(realm.objects(QuickNote.self))
            }
        }
    }
}
