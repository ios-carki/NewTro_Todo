import Foundation

protocol DeleteTemplateUseCaseProtocol {
    func execute(id: String) async throws
}

final class DeleteTemplateUseCase: DeleteTemplateUseCaseProtocol {
    private let repository: any TemplateRepositoryProtocol
    init(repository: any TemplateRepositoryProtocol) { self.repository = repository }
    func execute(id: String) async throws { try await repository.delete(id: id) }
}
