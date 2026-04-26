import Foundation

protocol ClearAllDataUseCaseProtocol {
    func execute() async throws
}

final class ClearAllDataUseCase: ClearAllDataUseCaseProtocol {
    private let todoRepository: any TodoRepositoryProtocol
    private let memoRepository: any MemoRepositoryProtocol
    private let statsRepository: any StatsRepositoryProtocol

    init(
        todoRepository: any TodoRepositoryProtocol,
        memoRepository: any MemoRepositoryProtocol,
        statsRepository: any StatsRepositoryProtocol
    ) {
        self.todoRepository = todoRepository
        self.memoRepository = memoRepository
        self.statsRepository = statsRepository
    }

    func execute() async throws {
        try await todoRepository.deleteAll()
        try await memoRepository.deleteAll()
        await statsRepository.resetAll()
    }
}
