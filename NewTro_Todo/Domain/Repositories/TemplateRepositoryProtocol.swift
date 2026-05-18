import Foundation

protocol TemplateRepositoryProtocol {
    func fetchAll() async throws -> [TemplateEntity]
    func add(text: String, importance: Importance) async throws -> TemplateEntity
    func update(id: String, text: String, importance: Importance) async throws
    func delete(id: String) async throws
}
