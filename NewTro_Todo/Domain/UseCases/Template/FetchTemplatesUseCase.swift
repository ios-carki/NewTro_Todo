import Foundation

protocol FetchTemplatesUseCaseProtocol {
    func execute() async throws -> [TemplateEntity]
}

final class FetchTemplatesUseCase: FetchTemplatesUseCaseProtocol {
    private let repository: any TemplateRepositoryProtocol
    init(repository: any TemplateRepositoryProtocol) { self.repository = repository }
    func execute() async throws -> [TemplateEntity] { try await repository.fetchAll() }
}
