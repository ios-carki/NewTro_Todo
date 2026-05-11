import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {

    enum TimeMode: String {
        case system
        case custom
    }

    // 시스템 기본 알림 시각
    static let morningDefault:  (hour: Int, minute: Int) = (7, 0)
    static let midnightDefault: (hour: Int, minute: Int) = (23, 55)

    // MARK: - Settings (UserDefaults 동기화)
    @Published var welcomeOnLaunch: Bool {
        didSet { UserDefaults.standard.set(welcomeOnLaunch, forKey: "showWelcomeOnLaunch") }
    }
    @Published var selectedCharacterId: String {
        didSet { UserDefaults.standard.set(selectedCharacterId, forKey: "selectedCharacterId") }
    }

    // MARK: - Notification State
    @Published private(set) var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: Self.keyEnabled) }
    }
    @Published var morningMode: TimeMode {
        didSet {
            UserDefaults.standard.set(morningMode.rawValue, forKey: Self.keyMorningMode)
            reapplyNotifications()
        }
    }
    @Published var morningCustomHour: Int {
        didSet {
            UserDefaults.standard.set(morningCustomHour, forKey: Self.keyMorningHour)
            if morningMode == .custom { reapplyNotifications() }
        }
    }
    @Published var morningCustomMinute: Int {
        didSet {
            UserDefaults.standard.set(morningCustomMinute, forKey: Self.keyMorningMinute)
            if morningMode == .custom { reapplyNotifications() }
        }
    }
    @Published var midnightMode: TimeMode {
        didSet {
            UserDefaults.standard.set(midnightMode.rawValue, forKey: Self.keyMidnightMode)
            reapplyNotifications()
        }
    }
    @Published var midnightCustomHour: Int {
        didSet {
            UserDefaults.standard.set(midnightCustomHour, forKey: Self.keyMidnightHour)
            if midnightMode == .custom { reapplyNotifications() }
        }
    }
    @Published var midnightCustomMinute: Int {
        didSet {
            UserDefaults.standard.set(midnightCustomMinute, forKey: Self.keyMidnightMinute)
            if midnightMode == .custom { reapplyNotifications() }
        }
    }

    @Published var showPermissionDeniedAlert = false
    @Published var showResetConfirm = false
    @Published var isMascotBobbing = false

    // MARK: - Callbacks
    var onResetComplete: (() -> Void)?

    // MARK: - UseCases
    private let clearAllDataUseCase: any ClearAllDataUseCaseProtocol
    private let checkPermissionUseCase: any CheckNotificationPermissionUseCaseProtocol
    private let requestPermissionUseCase: any RequestNotificationPermissionUseCaseProtocol
    private let applyNotificationsUseCase: any ApplyDailyNotificationsUseCaseProtocol

    init(
        clearAllDataUseCase: any ClearAllDataUseCaseProtocol,
        checkNotificationPermissionUseCase: any CheckNotificationPermissionUseCaseProtocol,
        requestNotificationPermissionUseCase: any RequestNotificationPermissionUseCaseProtocol,
        applyDailyNotificationsUseCase: any ApplyDailyNotificationsUseCaseProtocol
    ) {
        self.clearAllDataUseCase = clearAllDataUseCase
        self.checkPermissionUseCase = checkNotificationPermissionUseCase
        self.requestPermissionUseCase = requestNotificationPermissionUseCase
        self.applyNotificationsUseCase = applyDailyNotificationsUseCase

        let ud = UserDefaults.standard
        self.welcomeOnLaunch     = ud.bool(forKey: "showWelcomeOnLaunch")
        self.selectedCharacterId = ud.string(forKey: "selectedCharacterId") ?? "pinko"

        self.notificationsEnabled = ud.bool(forKey: Self.keyEnabled)
        self.morningMode = TimeMode(rawValue: ud.string(forKey: Self.keyMorningMode) ?? "") ?? .system
        self.midnightMode = TimeMode(rawValue: ud.string(forKey: Self.keyMidnightMode) ?? "") ?? .system
        self.morningCustomHour   = ud.object(forKey: Self.keyMorningHour) as? Int ?? Self.morningDefault.hour
        self.morningCustomMinute = ud.object(forKey: Self.keyMorningMinute) as? Int ?? Self.morningDefault.minute
        self.midnightCustomHour   = ud.object(forKey: Self.keyMidnightHour) as? Int ?? Self.midnightDefault.hour
        self.midnightCustomMinute = ud.object(forKey: Self.keyMidnightMinute) as? Int ?? Self.midnightDefault.minute
    }

    // MARK: - Notification Public API
    func toggleNotifications() {
        if notificationsEnabled {
            notificationsEnabled = false
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
            }
            reapplyNotifications()
        }
    }

    private func enableNotifications() async {
        let status = await checkPermissionUseCase.execute()
        switch status {
        case .notDetermined:
            do {
                let granted = try await requestPermissionUseCase.execute()
                if granted {
                    notificationsEnabled = true
                    reapplyNotifications()
                } else {
                    showPermissionDeniedAlert = true
                }
            } catch {
                showPermissionDeniedAlert = true
            }
        case .authorized:
            notificationsEnabled = true
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

    // MARK: - Computed
    var effectiveMorningTime: (hour: Int, minute: Int) {
        morningMode == .system
            ? Self.morningDefault
            : (morningCustomHour, morningCustomMinute)
    }

    var effectiveMidnightTime: (hour: Int, minute: Int) {
        midnightMode == .system
            ? Self.midnightDefault
            : (midnightCustomHour, midnightCustomMinute)
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
}
