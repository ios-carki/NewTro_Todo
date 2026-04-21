import Foundation

protocol FetchOrCreateQuickNoteUseCaseProtocol {
    func execute(targetDate: Date) async throws -> QuickNoteEntity
}

final class FetchOrCreateQuickNoteUseCase: FetchOrCreateQuickNoteUseCaseProtocol {
    private let repository: QuickNoteRepositoryProtocol

    init(repository: QuickNoteRepositoryProtocol) {
        self.repository = repository
    }

    func execute(targetDate: Date) async throws -> QuickNoteEntity {
        return try await repository.fetchOrCreate(targetDate: targetDate)
    }
}
