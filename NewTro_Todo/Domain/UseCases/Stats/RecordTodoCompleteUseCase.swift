import Foundation

protocol RecordTodoCompleteUseCaseProtocol {
    func execute(wasPostponed: Bool, isPerfectDay: Bool, date: Date) async
}

final class RecordTodoCompleteUseCase: RecordTodoCompleteUseCaseProtocol {
    private let repository: any StatsRepositoryProtocol

    init(repository: any StatsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(wasPostponed: Bool, isPerfectDay: Bool, date: Date) async {
        await repository.recordCompletion(wasPostponed: wasPostponed, isPerfectDay: isPerfectDay, date: date)
    }
}
