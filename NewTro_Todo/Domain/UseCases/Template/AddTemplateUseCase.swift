import Foundation

protocol AddTemplateUseCaseProtocol {
    func execute(text: String, emoji: String, importance: Importance) async throws -> TemplateEntity
}

final class AddTemplateUseCase: AddTemplateUseCaseProtocol {
    private let repository: any TemplateRepositoryProtocol
    init(repository: any TemplateRepositoryProtocol) { self.repository = repository }
    func execute(text: String, emoji: String, importance: Importance) async throws -> TemplateEntity {
        try await repository.add(text: text, emoji: emoji, importance: importance)
    }
}
