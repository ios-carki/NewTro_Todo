import Foundation

protocol PostponeTodoUseCaseProtocol {
    func execute(id: String, toDate: Date) async throws
}

final class PostponeTodoUseCase: PostponeTodoUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String, toDate: Date) async throws {
        try await repository.postpone(id: id, toDate: toDate)
    }
}
