import Foundation

protocol CreateBackupUseCaseProtocol {
    func execute() async throws -> (url: URL, logEntry: BackupLogEntry)
}

final class CreateBackupUseCase: CreateBackupUseCaseProtocol {
    private let repository: any BackupRepositoryProtocol

    init(repository: any BackupRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> (url: URL, logEntry: BackupLogEntry) {
        try await repository.exportBackup()
    }
}
