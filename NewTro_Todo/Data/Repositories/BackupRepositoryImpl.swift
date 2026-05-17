import Foundation
import RealmSwift

final class BackupRepositoryImpl: BackupRepositoryProtocol {

    private let fileExtension = "ntbackup"
    private let statsRepository: any StatsRepositoryProtocol
    private let backupLogRepository: any BackupLogRepositoryProtocol

    init(
        statsRepository: any StatsRepositoryProtocol,
        backupLogRepository: any BackupLogRepositoryProtocol
    ) {
        self.statsRepository = statsRepository
        self.backupLogRepository = backupLogRepository
    }

    // MARK: - Export

    func exportBackup() async throws -> (url: URL, logEntry: BackupLogEntry) {
        let statsSnapshot = await statsRepository.exportSnapshot()
        let priorLogs = await backupLogRepository.fetchAll()
        return try await MainActor.run {
            let realm = try Realm()

            let todos = realm.objects(Todo.self).map(Self.makeRecord)
            let quickNotes = realm.objects(QuickNote.self).map(Self.makeRecord)
            let templates = realm.objects(TemplateObject.self).map(Self.makeRecord)
            let walletObj = realm.object(ofType: WalletObject.self, forPrimaryKey: WalletObject.singletonId)
            let wallet = walletObj.map(Self.makeRecord)

            let todoArr = Array(todos)
            let quickNoteArr = Array(quickNotes)
            let templateArr = Array(templates)

            let createdAt = Date()
            let counts = BackupCounts(
                todo: todoArr.count,
                quickNote: quickNoteArr.count,
                template: templateArr.count,
                wallet: wallet == nil ? 0 : 1,
                postpone: nil
            )
            let header = BackupHeader(
                appVersion: Self.bundleShortVersion(),
                schemaVersion: Int(RealmConfiguration.schemaVersion),
                createdAt: createdAt,
                counts: counts
            )

            // 이번 백업 자체를 기술하는 로그 엔트리를 파일에 합성 포함.
            // 호출 측이 저장 확정 시 동일 id로 UserDefaults에도 기록해야 merge 모드 dedupe 성립.
            let selfLog = BackupLogEntry(createdAt: createdAt, counts: counts)
            let logsWithSelf = priorLogs + [selfLog]

            let file = BackupFile(
                header: header,
                todos: todoArr,
                quickNotes: quickNoteArr,
                templates: templateArr,
                wallet: wallet,
                postponeEvents: nil,
                stats: statsSnapshot,
                backupLogs: logsWithSelf
            )

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.sortedKeys]
            let data: Data
            do {
                data = try encoder.encode(file)
            } catch {
                throw BackupError.writeFailed
            }

            let url = try Self.makeTempBackupURL(extension: fileExtension)
            do {
                try data.write(to: url, options: .atomic)
            } catch {
                throw BackupError.writeFailed
            }
            return (url, selfLog)
        }
    }

    // MARK: - Peek

    func peekHeader(at url: URL) async throws -> BackupHeader {
        let file = try Self.readAndDecode(url: url)
        return file.header
    }

    // MARK: - Restore

    func restoreBackup(from url: URL, mode: RestoreMode) async throws {
        let file = try Self.readAndDecode(url: url)
        try Self.validateSchemaVersion(file.header.schemaVersion)

        try await MainActor.run {
            let realm = try Realm()
            do {
                try realm.write {
                    switch mode {
                    case .overwrite:
                        realm.deleteAll()
                        Self.insertAll(file: file, into: realm)
                    case .merge:
                        Self.mergeIn(file: file, into: realm)
                        Self.recomputeWallet(in: realm)
                    }
                }
            } catch {
                throw BackupError.writeFailed
            }
        }

        // 구버전 백업 파일은 stats가 없으므로 그대로 두고 종료.
        if let stats = file.stats {
            await statsRepository.restoreSnapshot(stats, mode: mode)
        }
        if let logs = file.backupLogs {
            await backupLogRepository.restoreSnapshot(logs, mode: mode)
        }
    }

    // MARK: - Realm → Record

    private static func makeRecord(_ o: Todo) -> BackupTodoRecord {
        BackupTodoRecord(
            id: o.objectID.stringValue,
            todo: o.todo,
            favorite: o.favorite,
            importance: o.importance,
            regDate: o.regDate,
            stringDate: o.stringDate,
            targetDate: o.targetDate,
            isFinished: o.isFinished,
            emoji: nil,
            sortOrder: o.sortOrder,
            completedAt: o.completedAt,
            targetTimeStart: o.targetTimeStart,
            targetTimeEnd: o.targetTimeEnd,
            isAllDay: o.isAllDay,
            notifyAt: o.notifyAt,
            dueTime: nil,
            postponeCount: nil
        )
    }

    private static func makeRecord(_ o: QuickNote) -> BackupQuickNoteRecord {
        BackupQuickNoteRecord(
            id: o.objectID.stringValue,
            note: o.note,
            regDate: o.regDate,
            stringToRegDate: o.stringToRegDate,
            targetDate: o.targetDate,
            isWrited: o.isWrited,
            colorName: o.colorName
        )
    }

    private static func makeRecord(_ o: TemplateObject) -> BackupTemplateRecord {
        BackupTemplateRecord(
            id: o.id,
            text: o.text,
            emoji: nil,
            importance: o.importance,
            createdAt: o.createdAt
        )
    }

    private static func makeRecord(_ o: WalletObject) -> BackupWalletRecord {
        BackupWalletRecord(id: o.id, balance: o.balance, totalEarned: o.totalEarned)
    }

    // MARK: - Record → Realm

    private static func buildTodo(from r: BackupTodoRecord) throws -> Todo {
        let t = Todo()
        t.objectID = try ObjectId(string: r.id)
        t.todo = r.todo
        t.favorite = r.favorite
        t.importance = r.importance
        t.regDate = r.regDate
        t.stringDate = r.stringDate
        t.targetDate = r.targetDate
        t.isFinished = r.isFinished
        // v11: 이모지 제거. 옛 백업의 r.emoji 값은 무시.
        t.sortOrder = r.sortOrder
        t.completedAt = r.completedAt
        // v10 신규 필드가 있으면 그대로 적용, 없고 레거시 dueTime만 있으면 진행 시각=알림 시각으로 fallback.
        // postponeCount는 무시 — 미루기 기능 자체가 제거됨.
        if r.targetTimeStart != nil || r.notifyAt != nil || r.isAllDay != nil {
            t.targetTimeStart = r.targetTimeStart
            t.targetTimeEnd = r.targetTimeEnd
            t.isAllDay = r.isAllDay ?? false
            t.notifyAt = r.notifyAt
        } else if let due = r.dueTime {
            t.targetTimeStart = due
            t.targetTimeEnd = nil
            t.isAllDay = false
            t.notifyAt = due
        }
        return t
    }

    private static func buildQuickNote(from r: BackupQuickNoteRecord) throws -> QuickNote {
        let n = QuickNote()
        n.objectID = try ObjectId(string: r.id)
        n.note = r.note
        n.regDate = r.regDate
        n.stringToRegDate = r.stringToRegDate
        n.targetDate = r.targetDate
        n.isWrited = r.isWrited
        n.colorName = r.colorName
        return n
    }

    private static func buildTemplate(from r: BackupTemplateRecord) -> TemplateObject {
        let t = TemplateObject()
        t.id = r.id
        t.text = r.text
        // v11: 이모지 제거. 옛 백업의 r.emoji 값은 무시.
        t.importance = r.importance
        t.createdAt = r.createdAt
        return t
    }

    private static func buildWallet(from r: BackupWalletRecord) -> WalletObject {
        let w = WalletObject()
        w.id = r.id
        w.balance = r.balance
        w.totalEarned = r.totalEarned
        return w
    }

    // MARK: - Insert (overwrite)

    private static func insertAll(file: BackupFile, into realm: Realm) {
        for r in file.todos {
            guard let obj = try? buildTodo(from: r) else { continue }
            realm.add(obj)
        }
        for r in file.quickNotes {
            guard let obj = try? buildQuickNote(from: r) else { continue }
            realm.add(obj)
        }
        for r in file.templates {
            realm.add(buildTemplate(from: r))
        }
        if let r = file.wallet {
            realm.add(buildWallet(from: r))
        }
        // v10에서 PostponeEvent 제거. 옛 백업의 postponeEvents 배열은 import 시 무시.
    }

    // MARK: - Merge

    private static func mergeIn(file: BackupFile, into realm: Realm) {
        // PK 충돌 시 백업 측 skip (기존 데이터 보존). UUID/ObjectId가 다른 기기에서 만들어지면 충돌 거의 없음.
        for r in file.todos {
            guard let pk = try? ObjectId(string: r.id) else { continue }
            if realm.object(ofType: Todo.self, forPrimaryKey: pk) != nil { continue }
            guard let obj = try? buildTodo(from: r) else { continue }
            realm.add(obj)
        }
        for r in file.quickNotes {
            guard let pk = try? ObjectId(string: r.id) else { continue }
            if realm.object(ofType: QuickNote.self, forPrimaryKey: pk) != nil { continue }
            guard let obj = try? buildQuickNote(from: r) else { continue }
            realm.add(obj)
        }
        for r in file.templates {
            if realm.object(ofType: TemplateObject.self, forPrimaryKey: r.id) != nil { continue }
            realm.add(buildTemplate(from: r))
        }
        // v10에서 PostponeEvent 제거. 옛 백업의 postponeEvents 배열은 merge 시 무시.
        // Wallet은 mergeIn에서 건드리지 않음 — recomputeWallet에서 처리.
    }

    // 병합 후 Wallet 정합성 보장: 모든 완료 Todo + 작성된 QuickNote 가중치로 totalEarned/balance 재계산.
    // 가중치는 RealmConfiguration v8 마이그 로직과 동일 (Importance.coinValue).
    private static func recomputeWallet(in realm: Realm) {
        var total = 0
        for todo in realm.objects(Todo.self) {
            guard todo.isFinished else { continue }
            let importance = Importance(rawValue: todo.importance) ?? .none
            total += importance.coinValue
        }
        for note in realm.objects(QuickNote.self) {
            if note.isWrited { total += 1 }
        }
        let wallet = realm.object(ofType: WalletObject.self, forPrimaryKey: WalletObject.singletonId)
            ?? {
                let w = WalletObject()
                realm.add(w)
                return w
            }()
        wallet.balance = total
        wallet.totalEarned = total
    }

    // MARK: - File IO helpers

    private static func readAndDecode(url: URL) throws -> BackupFile {
        // iCloud Drive에서 고른 파일은 security-scoped URL일 수 있음.
        let needsScope = url.startAccessingSecurityScopedResource()
        defer { if needsScope { url.stopAccessingSecurityScopedResource() } }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw BackupError.fileNotReadable
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(BackupFile.self, from: data)
        } catch {
            throw BackupError.decodeFailed
        }
    }

    private static func validateSchemaVersion(_ version: Int) throws {
        let current = Int(RealmConfiguration.schemaVersion)
        // 같거나 낮은 버전만 허용. 미래 버전은 거절.
        if version > current {
            throw BackupError.unsupportedSchemaVersion(found: version, current: current)
        }
    }

    private static func makeTempBackupURL(extension ext: String) throws -> URL {
        let dir = FileManager.default.temporaryDirectory
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmm"
        let stamp = formatter.string(from: Date())
        let name = "NewTroTodo-Backup-\(stamp).\(ext)"
        return dir.appendingPathComponent(name)
    }

    private static func bundleShortVersion() -> String {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0.0.0"
    }
}
