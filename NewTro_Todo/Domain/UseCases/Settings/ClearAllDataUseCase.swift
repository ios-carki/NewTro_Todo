import Foundation

protocol ClearAllDataUseCaseProtocol {
    func execute() async throws
}

final class ClearAllDataUseCase: ClearAllDataUseCaseProtocol {
    private let todoRepository: TodoRepositoryProtocol
    private let quickNoteRepository: QuickNoteRepositoryProtocol

    init(todoRepository: TodoRepositoryProtocol, quickNoteRepository: QuickNoteRepositoryProtocol) {
        self.todoRepository = todoRepository
        self.quickNoteRepository = quickNoteRepository
    }

    func execute() async throws {
        try await todoRepository.deleteAll()
        try await quickNoteRepository.deleteAll()
    }
}
