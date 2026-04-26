import Foundation

protocol DeleteMemoUseCaseProtocol {
    func execute(id: String) async throws
}

final class DeleteMemoUseCase: DeleteMemoUseCaseProtocol {
    private let repository: any MemoRepositoryProtocol

    init(repository: any MemoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String) async throws {
        try await repository.deleteMemo(id: id)
    }
}
