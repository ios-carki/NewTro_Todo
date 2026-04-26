import Foundation

protocol FetchMemosUseCaseProtocol {
    func execute(filter: MemoFilter) async throws -> [MemoEntity]
}

final class FetchMemosUseCase: FetchMemosUseCaseProtocol {
    private let repository: any MemoRepositoryProtocol

    init(repository: any MemoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(filter: MemoFilter) async throws -> [MemoEntity] {
        let cal = Calendar.current
        switch filter {
        case .all:
            return try await repository.fetchAll()
        case .today:
            let start = cal.startOfDay(for: Date())
            let end = cal.date(byAdding: .day, value: 1, to: start) ?? start
            return try await repository.fetchMemos(from: start, to: end)
        case .days(let n):
            let end = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: Date())) ?? Date()
            let start = cal.date(byAdding: .day, value: -n, to: end) ?? end
            return try await repository.fetchMemos(from: start, to: end)
        case .range(let from, let to):
            let start = cal.startOfDay(for: from)
            let end = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: to)) ?? to
            return try await repository.fetchMemos(from: start, to: end)
        }
    }
}
