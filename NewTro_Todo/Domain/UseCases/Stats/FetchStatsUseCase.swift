import Foundation

protocol FetchStatsUseCaseProtocol {
    func execute() async -> StatsEntity
}

final class FetchStatsUseCase: FetchStatsUseCaseProtocol {
    private let repository: any StatsRepositoryProtocol

    init(repository: any StatsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async -> StatsEntity {
        await repository.fetchStats()
    }
}
