import Foundation

protocol UpdateMemoUseCaseProtocol {
    func execute(id: String, note: String, colorName: String) async throws
}

final class UpdateMemoUseCase: UpdateMemoUseCaseProtocol {
    private let repository: any MemoRepositoryProtocol

    init(repository: any MemoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String, note: String, colorName: String) async throws {
        try await repository.updateMemo(id: id, note: note, colorName: colorName)
    }
}
