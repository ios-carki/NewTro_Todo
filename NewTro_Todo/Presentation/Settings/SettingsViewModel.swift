import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {

    enum TimeMode: String {
        case system
        case custom
    }

    enum BackupPhase: Equatable {
        case idle
        case running   // 저장 직후 잠깐 보이는 상태 모달 (UI 연속성용)
        case success
        case error(String)

        var isActive: Bool { self != .idle }
    }

    enum RestorePhase: Equatable {
        case idle
        case running
        case done
        case error(String)

        var isActive: Bool { self != .idle }
    }

    struct RestorePreview: Equatable {
        let url: URL
        let header: BackupHeader
        static func == (lhs: RestorePreview, rhs: RestorePreview) -> Bool {
            lhs.url == rhs.url && lhs.header.createdAt == rhs.header.createdAt
        }
    }

    static let morningDefault:  (hour: Int, minute: Int) = (7, 0)
    static let midnightDefault: (hour: Int, minute: Int) = (23, 55)

    // MARK: - Settings (UserDefaults 동기화)
    @Published var welcomeOnLaunch: Bool {
        didSet { UserDefaults.standard.set(welcomeOnLaunch, forKey: "showWelcomeOnLaunch") }
    }
    @Published var selectedCharacterId: String {
        didSet { UserDefaults.standard.set(selectedCharacterId, forKey: "selectedCharacterId") }
    }

    // MARK: - Notification State (mutation은 메서드를 통해서만)
    @Published private(set) var notificationsEnabled: Bool
    @Published private(set) var morningMode: TimeMode
    @Published private(set) var morningHour: Int
    @Published private(set) var morningMinute: Int
    @Published private(set) var midnightMode: TimeMode
    @Published private(set) var midnightHour: Int
    @Published private(set) var midnightMinute: Int

    @Published var showPermissionDeniedAlert = false
    @Published var showResetConfirm = false
    @Published var isMascotBobbing = false

    // MARK: - Backup / Restore State
    @Published private(set) var backupPhase: BackupPhase = .idle
    @Published private(set) var restorePhase: RestorePhase = .idle
    @Published private(set) var lastBackupAt: Date?
    @Published private(set) var backupCount: Int

    // 파일 저장(export)·불러오기(import) Document Picker 제어 플래그
    @Published var showExportPicker: Bool = false
    @Published var showImportPicker: Bool = false
    @Published var restorePreview: RestorePreview?

    private(set) var pendingExportURL: URL?

    var onResetComplete: (() -> Void)?
    var onRestoreComplete: (() -> Void)?

    private let clearAllDataUseCase: any ClearAllDataUseCaseProtocol
    private let checkPermissionUseCase: any CheckNotificationPermissionUseCaseProtocol
    private let requestPermissionUseCase: any RequestNotificationPermissionUseCaseProtocol
    private let applyNotificationsUseCase: any ApplyDailyNotificationsUseCaseProtocol
    private let createBackupUseCase: any CreateBackupUseCaseProtocol
    private let restoreBackupUseCase: any RestoreBackupUseCaseProtocol
    private let peekBackupHeaderUseCase: any PeekBackupHeaderUseCaseProtocol
    private let recordBackupLogUseCase: any RecordBackupLogUseCaseProtocol

    // 백업 성공 시 RecordBackupLog 에 넘길 counts. 임시 백업 URL 생성 시 함께 메모이즈.
    private var pendingBackupCounts: BackupCounts?

    init(
        clearAllDataUseCase: any ClearAllDataUseCaseProtocol,
        checkNotificationPermissionUseCase: any CheckNotificationPermissionUseCaseProtocol,
        requestNotificationPermissionUseCase: any RequestNotificationPermissionUseCaseProtocol,
        applyDailyNotificationsUseCase: any ApplyDailyNotificationsUseCaseProtocol,
        createBackupUseCase: any CreateBackupUseCaseProtocol,
        restoreBackupUseCase: any RestoreBackupUseCaseProtocol,
        peekBackupHeaderUseCase: any PeekBackupHeaderUseCaseProtocol,
        recordBackupLogUseCase: any RecordBackupLogUseCaseProtocol
    ) {
        self.clearAllDataUseCase = clearAllDataUseCase
        self.checkPermissionUseCase = checkNotificationPermissionUseCase
        self.requestPermissionUseCase = requestNotificationPermissionUseCase
        self.applyNotificationsUseCase = applyDailyNotificationsUseCase
        self.createBackupUseCase = createBackupUseCase
        self.restoreBackupUseCase = restoreBackupUseCase
        self.peekBackupHeaderUseCase = peekBackupHeaderUseCase
        self.recordBackupLogUseCase = recordBackupLogUseCase

        let ud = UserDefaults.standard
        self.welcomeOnLaunch     = ud.bool(forKey: "showWelcomeOnLaunch")
        self.selectedCharacterId = ud.string(forKey: "selectedCharacterId") ?? "pinko"

        self.notificationsEnabled = ud.bool(forKey: Self.keyEnabled)
        self.morningMode  = TimeMode(rawValue: ud.string(forKey: Self.keyMorningMode) ?? "") ?? .system
        self.midnightMode = TimeMode(rawValue: ud.string(forKey: Self.keyMidnightMode) ?? "") ?? .system
        self.morningHour   = ud.object(forKey: Self.keyMorningHour) as? Int ?? Self.morningDefault.hour
        self.morningMinute = ud.object(forKey: Self.keyMorningMinute) as? Int ?? Self.morningDefault.minute
        self.midnightHour   = ud.object(forKey: Self.keyMidnightHour) as? Int ?? Self.midnightDefault.hour
        self.midnightMinute = ud.object(forKey: Self.keyMidnightMinute) as? Int ?? Self.midnightDefault.minute

        self.lastBackupAt = ud.object(forKey: Self.keyBackupLastAt) as? Date
        self.backupCount  = ud.integer(forKey: Self.keyBackupCount)
    }

    // MARK: - Notification Public API
    func toggleNotifications() {
        if notificationsEnabled {
            notificationsEnabled = false
            persistEnabled()
            reapplyNotifications()
        } else {
            Task { await enableNotifications() }
        }
    }

    func refreshNotificationStateOnAppear() {
        Task {
            let status = await checkPermissionUseCase.execute()
            if notificationsEnabled, status != .authorized {
                notificationsEnabled = false
                persistEnabled()
            }
            reapplyNotifications()
        }
    }

    func saveCustomNotificationTimes(
        morning: (hour: Int, minute: Int),
        midnight: (hour: Int, minute: Int)
    ) {
        morningMode  = .custom
        midnightMode = .custom
        morningHour   = morning.hour
        morningMinute = morning.minute
        midnightHour   = midnight.hour
        midnightMinute = midnight.minute
        persistTimes()
        reapplyNotifications()
    }

    func resetNotificationTimesToSystem() {
        morningMode  = .system
        midnightMode = .system
        morningHour   = Self.morningDefault.hour
        morningMinute = Self.morningDefault.minute
        midnightHour   = Self.midnightDefault.hour
        midnightMinute = Self.midnightDefault.minute
        persistTimes()
        reapplyNotifications()
    }

    private func enableNotifications() async {
        let status = await checkPermissionUseCase.execute()
        switch status {
        case .notDetermined:
            do {
                let granted = try await requestPermissionUseCase.execute()
                if granted {
                    notificationsEnabled = true
                    persistEnabled()
                    reapplyNotifications()
                } else {
                    showPermissionDeniedAlert = true
                }
            } catch {
                showPermissionDeniedAlert = true
            }
        case .authorized:
            notificationsEnabled = true
            persistEnabled()
            reapplyNotifications()
        case .denied:
            showPermissionDeniedAlert = true
        }
    }

    private func reapplyNotifications() {
        let morning  = effectiveMorningTime
        let midnight = effectiveMidnightTime
        let enabled  = notificationsEnabled
        Task {
            try? await applyNotificationsUseCase.execute(
                enabled: enabled,
                morning: morning,
                midnight: midnight
            )
        }
    }

    // MARK: - Backup Public API

    func startBackup() {
        guard !backupPhase.isActive, !showExportPicker else { return }
        // 임시 파일 생성은 < 100ms 이므로 진행 모달 없이 바로 picker로 진입.
        Task {
            do {
                let url = try await createBackupUseCase.execute()
                // 백업 로그용 counts 미리 capture — 저장 확정 시 RecordBackupLog 에 전달.
                pendingBackupCounts = (try? await peekBackupHeaderUseCase.execute(at: url))?.counts
                pendingExportURL = url
                showExportPicker = true
            } catch {
                backupPhase = .error("백업 파일을 만들지 못했어요.".localized())
            }
        }
    }

    func dismissBackupProgressModal() {
        backupPhase = .idle
    }

    // UIDocumentPicker(forExporting:) 결과 처리.
    // 저장 성공 시 → 메타데이터 업데이트 + 상태 팝업(.running → .success).
    // 취소 시 → 조용히 정리, 팝업 없음.
    func handleExportResult(saved: Bool) {
        showExportPicker = false
        if let url = pendingExportURL {
            try? FileManager.default.removeItem(at: url)
            pendingExportURL = nil
        }
        let counts = pendingBackupCounts
        pendingBackupCounts = nil
        guard saved else { return }

        let now = Date()
        lastBackupAt = now
        backupCount += 1
        let ud = UserDefaults.standard
        ud.set(now, forKey: Self.keyBackupLastAt)
        ud.set(backupCount, forKey: Self.keyBackupCount)

        // 백업 로그 기록 (peek 실패로 counts가 없으면 0으로 채워서라도 timestamp 보존).
        let logCounts = counts ?? BackupCounts(todo: 0, quickNote: 0, template: 0, wallet: 0, postpone: 0)
        Task { await recordBackupLogUseCase.execute(counts: logCounts) }

        backupPhase = .running
        Task {
            try? await Task.sleep(nanoseconds: 450_000_000) // ~0.45s 상태 모달 노출
            backupPhase = .success
        }
    }

    // MARK: - Restore Public API

    func startRestoreFlow() {
        guard !restorePhase.isActive, restorePreview == nil else { return }
        showImportPicker = true
    }

    // 파일 선택 후 헤더 미리보기 시도. 실패 시 에러 모달.
    func handleImportPicked(url: URL) {
        showImportPicker = false
        Task {
            do {
                let header = try await peekBackupHeaderUseCase.execute(at: url)
                restorePreview = RestorePreview(url: url, header: header)
            } catch BackupError.unsupportedSchemaVersion {
                restorePhase = .error("지원하지 않는 버전의 백업 파일입니다.\n앱을 최신 버전으로 업데이트해주세요.".localized())
            } catch {
                restorePhase = .error("백업 파일을 읽을 수 없어요.".localized())
            }
        }
    }

    func cancelRestorePreview() {
        restorePreview = nil
    }

    func confirmRestore(mode: RestoreMode) {
        guard let preview = restorePreview else { return }
        restorePreview = nil
        restorePhase = .running
        let url = preview.url
        Task {
            do {
                try await restoreBackupUseCase.execute(from: url, mode: mode)
                restorePhase = .done
            } catch BackupError.unsupportedSchemaVersion {
                restorePhase = .error("지원하지 않는 버전의 백업 파일입니다.\n앱을 최신 버전으로 업데이트해주세요.".localized())
            } catch {
                restorePhase = .error("복구를 완료하지 못했어요.".localized())
            }
        }
    }

    func dismissRestoreProgressModal() {
        let shouldReload: Bool = {
            if case .done = restorePhase { return true } else { return false }
        }()
        restorePhase = .idle
        if shouldReload { onRestoreComplete?() }
    }

    // MARK: - Persistence
    private func persistEnabled() {
        UserDefaults.standard.set(notificationsEnabled, forKey: Self.keyEnabled)
    }

    private func persistTimes() {
        let ud = UserDefaults.standard
        ud.set(morningMode.rawValue,  forKey: Self.keyMorningMode)
        ud.set(midnightMode.rawValue, forKey: Self.keyMidnightMode)
        ud.set(morningHour,   forKey: Self.keyMorningHour)
        ud.set(morningMinute, forKey: Self.keyMorningMinute)
        ud.set(midnightHour,   forKey: Self.keyMidnightHour)
        ud.set(midnightMinute, forKey: Self.keyMidnightMinute)
    }

    // MARK: - Computed
    var effectiveMorningTime: (hour: Int, minute: Int) {
        morningMode == .system
            ? Self.morningDefault
            : (morningHour, morningMinute)
    }

    var effectiveMidnightTime: (hour: Int, minute: Int) {
        midnightMode == .system
            ? Self.midnightDefault
            : (midnightHour, midnightMinute)
    }

    var isCustomNotificationTimes: Bool {
        morningMode == .custom || midnightMode == .custom
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0.0"
    }

    // MARK: - Reset
    func confirmReset() {
        showResetConfirm = true
    }

    func resetAllData() {
        Task {
            do {
                try await clearAllDataUseCase.execute()
                UserDefaults.standard.removeObject(forKey: "welcomeSeenVersion")
                onResetComplete?()
            } catch {
                onResetComplete?()
            }
        }
    }

    // MARK: - UserDefaults Keys
    private static let keyEnabled        = "notifications.enabled"
    private static let keyMorningMode    = "notifications.morning.mode"
    private static let keyMorningHour    = "notifications.morning.hour"
    private static let keyMorningMinute  = "notifications.morning.minute"
    private static let keyMidnightMode   = "notifications.midnight.mode"
    private static let keyMidnightHour   = "notifications.midnight.hour"
    private static let keyMidnightMinute = "notifications.midnight.minute"
    private static let keyBackupLastAt   = "backup.lastAt"
    private static let keyBackupCount    = "backup.count"
}
