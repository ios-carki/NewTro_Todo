import Foundation

protocol RecordBackupLogUseCaseProtocol {
    func execute(entry: BackupLogEntry) async
}

final class RecordBackupLogUseCase: RecordBackupLogUseCaseProtocol {
    private let repository: any BackupLogRepositoryProtocol

    init(repository: any BackupLogRepositoryProtocol) {
        self.repository = repository
    }

    func execute(entry: BackupLogEntry) async {
        await repository.append(entry)
    }
}
