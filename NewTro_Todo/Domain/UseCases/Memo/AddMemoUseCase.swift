import Foundation

protocol AddMemoUseCaseProtocol {
    func execute(colorName: String) async throws -> MemoEntity
}

final class AddMemoUseCase: AddMemoUseCaseProtocol {
    private let repository: any MemoRepositoryProtocol

    init(repository: any MemoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(colorName: String) async throws -> MemoEntity {
        try await repository.addMemo(colorName: colorName)
    }
}
