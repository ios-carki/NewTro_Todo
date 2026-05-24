import Foundation

protocol FetchWeeklyTodoCountsUseCaseProtocol {
    func execute() async throws -> [Int]
}

final class FetchWeeklyTodoCountsUseCase: FetchWeeklyTodoCountsUseCaseProtocol {
    private let repository: any TodoRepositoryProtocol

    init(repository: any TodoRepositoryProtocol) {
        self.repository = repository
    }

    // index 0 = 6 days ago, index 6 = today
    // count = 그 날 targetDate 로 작성된 Todo 전체 (완료 여부 무관)
    func execute() async throws -> [Int] {
        let cal = Calendar.current
        var counts = [Int]()
        for i in 0..<7 {
            let date = cal.date(byAdding: .day, value: -(6 - i), to: Date()) ?? Date()
            let todos = try await repository.fetchTodos(targetDate: date)
            counts.append(todos.count)
        }
        return counts
    }
}
