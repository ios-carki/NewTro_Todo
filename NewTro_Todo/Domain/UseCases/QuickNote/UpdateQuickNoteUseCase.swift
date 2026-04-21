import Foundation

protocol UpdateQuickNoteUseCaseProtocol {
    func execute(id: String, note: String) async throws
}

final class UpdateQuickNoteUseCase: UpdateQuickNoteUseCaseProtocol {
    private let repository: QuickNoteRepositoryProtocol

    init(repository: QuickNoteRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String, note: String) async throws {
        try await repository.updateNote(id: id, note: note)
    }
}
