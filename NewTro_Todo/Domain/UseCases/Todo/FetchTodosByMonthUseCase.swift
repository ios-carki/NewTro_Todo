import Foundation

protocol FetchTodosByMonthUseCaseProtocol {
    func execute(year: Int, month: Int) async throws -> [TodoEntity]
}

final class FetchTodosByMonthUseCase: FetchTodosByMonthUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(year: Int, month: Int) async throws -> [TodoEntity] {
        try await repository.fetchTodos(year: year, month: month)
    }
}
