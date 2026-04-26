import Foundation

protocol RecordPostponeUseCaseProtocol {
    func execute() async
}

final class RecordPostponeUseCase: RecordPostponeUseCaseProtocol {
    private let repository: any StatsRepositoryProtocol

    init(repository: any StatsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async {
        await repository.recordPostpone()
    }
}
