import Foundation

protocol UpdateTemplateUseCaseProtocol {
    func execute(id: String, text: String, importance: Importance) async throws
}

final class UpdateTemplateUseCase: UpdateTemplateUseCaseProtocol {
    private let repository: any TemplateRepositoryProtocol
    init(repository: any TemplateRepositoryProtocol) { self.repository = repository }
    func execute(id: String, text: String, importance: Importance) async throws {
        try await repository.update(id: id, text: text, importance: importance)
    }
}
