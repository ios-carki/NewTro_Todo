import Foundation

protocol AddRoutineUseCaseProtocol {
    @MainActor func execute(_ entity: RoutineEntity) throws -> RoutineEntity
}

final class AddRoutineUseCase: AddRoutineUseCaseProtocol {
    private let repository: RoutineRepositoryProtocol

    init(repository: RoutineRepositoryProtocol) {
        self.repository = repository
    }

    @MainActor
    func execute(_ entity: RoutineEntity) throws -> RoutineEntity {
        try repository.add(entity)
    }
}
