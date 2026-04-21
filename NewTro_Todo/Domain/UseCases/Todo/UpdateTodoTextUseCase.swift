import Foundation

protocol UpdateTodoTextUseCaseProtocol {
    func execute(id: String, text: String) async throws
}

final class UpdateTodoTextUseCase: UpdateTodoTextUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String, text: String) async throws {
        try await repository.updateText(id: id, text: text)
    }
}
