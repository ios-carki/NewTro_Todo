import Foundation

protocol FetchWeeklyCompletionsUseCaseProtocol {
    func execute() async throws -> [Int]
}

final class FetchWeeklyCompletionsUseCase: FetchWeeklyCompletionsUseCaseProtocol {
    private let repository: any TodoRepositoryProtocol

    init(repository: any TodoRepositoryProtocol) {
        self.repository = repository
    }

    // Returns 7 values: index 0 = 6 days ago, index 6 = today
    func execute() async throws -> [Int] {
        let cal = Calendar.current
        var counts = [Int]()
        for i in 0..<7 {
            let date = cal.date(byAdding: .day, value: -(6 - i), to: Date()) ?? Date()
            let todos = try await repository.fetchTodos(targetDate: date)
            counts.append(todos.filter(\.isCompleted).count)
        }
        return counts
    }
}
