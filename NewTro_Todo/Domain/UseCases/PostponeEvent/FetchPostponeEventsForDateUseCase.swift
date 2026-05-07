import Foundation

protocol FetchPostponeEventsForDateUseCaseProtocol {
    func execute(date: Date) async throws -> [PostponeEventEntity]
}

final class FetchPostponeEventsForDateUseCase: FetchPostponeEventsForDateUseCaseProtocol {
    private let repository: any PostponeEventRepositoryProtocol
    init(repository: any PostponeEventRepositoryProtocol) {
        self.repository = repository
    }
    func execute(date: Date) async throws -> [PostponeEventEntity] {
        try await repository.fetchEvents(forDate: date)
    }
}
