import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {

    // MARK: - Settings (UserDefaults 동기화)
    @Published var welcomeOnLaunch: Bool {
        didSet { UserDefaults.standard.set(welcomeOnLaunch, forKey: "showWelcomeOnLaunch") }
    }
    @Published var selectedCharacterId: String {
        didSet { UserDefaults.standard.set(selectedCharacterId, forKey: "selectedCharacterId") }
    }
    @Published var showResetConfirm = false
    @Published var isMascotBobbing = false

    // MARK: - Callbacks
    var onResetComplete: (() -> Void)?

    private let clearAllDataUseCase: any ClearAllDataUseCaseProtocol

    init(clearAllDataUseCase: any ClearAllDataUseCaseProtocol) {
        self.clearAllDataUseCase = clearAllDataUseCase
        self.welcomeOnLaunch     = UserDefaults.standard.bool(forKey: "showWelcomeOnLaunch")
        self.selectedCharacterId = UserDefaults.standard.string(forKey: "selectedCharacterId") ?? "pinko"
    }

    // MARK: - Reset
    func confirmReset() {
        showResetConfirm = true
    }

    func resetAllData() {
        Task {
            do {
                try await clearAllDataUseCase.execute()
                // 다음 실행 시 WelcomeView 다시 보이도록 버전 키 초기화
                UserDefaults.standard.removeObject(forKey: "welcomeSeenVersion")
                onResetComplete?()
            } catch {
                // 실패해도 재시작 시도
                onResetComplete?()
            }
        }
    }

    // MARK: - Computed
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0.0"
    }
}
