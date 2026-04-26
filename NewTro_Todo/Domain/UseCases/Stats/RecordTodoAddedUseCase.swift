import Foundation

protocol RecordTodoAddedUseCaseProtocol {
    func execute() async
}

final class RecordTodoAddedUseCase: RecordTodoAddedUseCaseProtocol {
    private let repository: any StatsRepositoryProtocol

    init(repository: any StatsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async {
        await repository.recordTodoAdded()
    }
}
