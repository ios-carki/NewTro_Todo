import Foundation
import RealmSwift

final class PostponeEventRepositoryImpl: PostponeEventRepositoryProtocol {

    func append(todoId: String, eventDate: Date, ordinalAtTime: Int) async throws {
        try await MainActor.run {
            let realm = try Realm()
            let obj = PostponeEventObject(
                todoId: todoId,
                eventDate: eventDate,
                ordinalAtTime: ordinalAtTime
            )
            try realm.write { realm.add(obj) }
        }
    }

    func fetchEvents(forDate date: Date) async throws -> [PostponeEventEntity] {
        try await MainActor.run {
            let realm = try Realm()
            let cal = Calendar.current
            let dayStart = cal.startOfDay(for: date)
            guard let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart) else { return [] }
            return realm.objects(PostponeEventObject.self)
                .filter("eventDate >= %@ AND eventDate < %@", dayStart, dayEnd)
                .map { $0.toDomain() }
                .sorted { $0.eventDate < $1.eventDate }
        }
    }
}
