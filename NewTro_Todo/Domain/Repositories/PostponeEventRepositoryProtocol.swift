import Foundation

protocol PostponeEventRepositoryProtocol {
    func append(todoId: String, eventDate: Date, ordinalAtTime: Int) async throws
    func fetchEvents(forDate date: Date) async throws -> [PostponeEventEntity]
}
