import Foundation

protocol QuickNoteRepositoryProtocol {
    func fetchOrCreate(targetDate: Date) async throws -> QuickNoteEntity
    func updateNote(id: String, note: String) async throws
    func deleteAll() async throws
}
