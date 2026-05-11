import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {

    enum TimeMode: String {
        case system
        case custom
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

    var onResetComplete: (() -> Void)?

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
        self.morningMode  = TimeMode(rawValue: ud.string(forKey: Self.keyMorningMode) ?? "") ?? .system
        self.midnightMode = TimeMode(rawValue: ud.string(forKey: Self.keyMidnightMode) ?? "") ?? .system
        self.morningHour   = ud.object(forKey: Self.keyMorningHour) as? Int ?? Self.morningDefault.hour
        self.morningMinute = ud.object(forKey: Self.keyMorningMinute) as? Int ?? Self.morningDefault.minute
        self.midnightHour   = ud.object(forKey: Self.keyMidnightHour) as? Int ?? Self.midnightDefault.hour
        self.midnightMinute = ud.object(forKey: Self.keyMidnightMinute) as? Int ?? Self.midnightDefault.minute
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
}
