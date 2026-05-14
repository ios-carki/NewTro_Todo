import Foundation

enum BackupError: Error {
    case fileNotReadable
    case decodeFailed
    case unsupportedSchemaVersion(found: Int, current: Int)
    case writeFailed
}

protocol BackupRepositoryProtocol {
    // 현재 Realm 전체를 dump 해 임시 파일 + 이번 백업을 기술하는 로그 엔트리를 반환.
    // 반환된 로그 엔트리는 파일 내부에도 이미 포함되어 있고, 저장 확정 시 동일 id로
    // UserDefaults에 기록되어야 합치기 모드에서 dedupe가 성립한다.
    // 호출 측은 UIDocumentPicker로 사용자 위치 이동 후 임시 파일 cleanup 책임.
    func exportBackup() async throws -> (url: URL, logEntry: BackupLogEntry)

    // url의 헤더만 빠르게 읽어 미리보기 정보 반환. 본문은 디코드하지 않음.
    func peekHeader(at url: URL) async throws -> BackupHeader

    // url의 백업을 Realm에 적용. mode에 따라 동작.
    // - .overwrite: deleteAll + add 단일 트랜잭션
    // - .merge: 기존 데이터 유지 + 백업 데이터 add (id 충돌 시 백업측 skip), Wallet 합산 후 재계산
    func restoreBackup(from url: URL, mode: RestoreMode) async throws
}
