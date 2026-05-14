import Foundation

protocol CreateBackupUseCaseProtocol {
    func execute() async throws -> URL
}

final class CreateBackupUseCase: CreateBackupUseCaseProtocol {
    private let repository: any BackupRepositoryProtocol

    init(repository: any BackupRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> URL {
        try await repository.exportBackup()
    }
}
