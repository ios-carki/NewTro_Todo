import Foundation

protocol FetchWeeklyTodoCountsUseCaseProtocol {
    func execute() async throws -> [WeeklyDayCounts]
}

final class FetchWeeklyTodoCountsUseCase: FetchWeeklyTodoCountsUseCaseProtocol {
    private let repository: any TodoRepositoryProtocol

    init(repository: any TodoRepositoryProtocol) {
        self.repository = repository
    }

    // index 0 = 6 days ago, index 6 = today
    // 각 칸에 그 날의 (완료 수, 미완료 수) 를 분리해 담는다 — 그래프가 두 색 막대를 그릴 수 있도록.
    func execute() async throws -> [WeeklyDayCounts] {
        let cal = Calendar.current
        var results: [WeeklyDayCounts] = []
        for i in 0..<7 {
            let date = cal.date(byAdding: .day, value: -(6 - i), to: Date()) ?? Date()
            let todos = try await repository.fetchTodos(targetDate: date)
            let completed = todos.filter { $0.isCompleted }.count
            results.append(WeeklyDayCounts(completed: completed, incomplete: todos.count - completed))
        }
        return results
    }
}
