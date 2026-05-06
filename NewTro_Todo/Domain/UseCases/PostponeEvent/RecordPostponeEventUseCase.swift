import Foundation

protocol RecordPostponeEventUseCaseProtocol {
    func execute(todoId: String, eventDate: Date, ordinalAtTime: Int) async throws
}

final class RecordPostponeEventUseCase: RecordPostponeEventUseCaseProtocol {
    private let repository: any PostponeEventRepositoryProtocol
    init(repository: any PostponeEventRepositoryProtocol) {
        self.repository = repository
    }
    func execute(todoId: String, eventDate: Date, ordinalAtTime: Int) async throws {
        try await repository.append(todoId: todoId, eventDate: eventDate, ordinalAtTime: ordinalAtTime)
    }
}
