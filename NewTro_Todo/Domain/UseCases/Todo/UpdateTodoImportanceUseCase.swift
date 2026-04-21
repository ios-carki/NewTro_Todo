import Foundation

protocol UpdateTodoImportanceUseCaseProtocol {
    func execute(id: String, importance: Importance) async throws
}

final class UpdateTodoImportanceUseCase: UpdateTodoImportanceUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String, importance: Importance) async throws {
        try await repository.updateImportance(id: id, importance: importance)
    }
}
