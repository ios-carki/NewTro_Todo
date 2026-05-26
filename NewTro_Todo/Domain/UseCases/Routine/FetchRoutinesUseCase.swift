import Foundation

protocol FetchRoutinesUseCaseProtocol {
    @MainActor func execute() throws -> [RoutineEntity]
}

final class FetchRoutinesUseCase: FetchRoutinesUseCaseProtocol {
    private let repository: RoutineRepositoryProtocol

    init(repository: RoutineRepositoryProtocol) {
        self.repository = repository
    }

    @MainActor
    func execute() throws -> [RoutineEntity] {
        try repository.fetchAll()
    }
}
