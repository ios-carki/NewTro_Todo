import UIKit

final class AppCoordinator: CoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [any CoordinatorProtocol] = []

    private let window: UIWindow
    private let diContainer: DIContainer

    init(window: UIWindow, diContainer: DIContainer) {
        self.window = window
        self.diContainer = diContainer
        self.navigationController = UINavigationController()
    }

    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        showSplash()
    }

    // MARK: - Splash (심플 로딩, 1.5s)
    private func showSplash() {
        let coordinator = SplashCoordinator(navigationController: navigationController)
        coordinator.onFinished = { [weak self, weak coordinator] in
            self?.remove(coordinator)
            if self?.shouldShowWelcome == true {
                self?.showWelcome()
            } else {
                self?.showMain()
            }
        }
        childCoordinators.append(coordinator)
        coordinator.start()
    }

    // MARK: - Welcome (최초 실행 or 설정 토글 ON)
    private func showWelcome() {
        let coordinator = WelcomeCoordinator(navigationController: navigationController)
        coordinator.onFinished = { [weak self, weak coordinator] in
            self?.remove(coordinator)
            self?.showMain()
        }
        childCoordinators.append(coordinator)
        coordinator.start()
    }

    // MARK: - Main
    private func showMain() {
        let coordinator = MainCoordinator(
            navigationController: navigationController,
            diContainer: diContainer
        )
        childCoordinators.append(coordinator)
        coordinator.start()
    }

    // MARK: - Welcome 표시 조건
    // - welcomeSeenVersion 키 없음 (신규 설치 or v1→v2 업데이트)
    // - 저장된 버전이 현재 앱 버전과 다름 (업데이트)
    // - 설정에서 "앱 시작 시 소개 화면 보기" ON
    private var shouldShowWelcome: Bool {
        let seenVersion = UserDefaults.standard.string(forKey: "welcomeSeenVersion")
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0.0"
        let showAlways = UserDefaults.standard.bool(forKey: "showWelcomeOnLaunch")
        return seenVersion != currentVersion || showAlways
    }

    private func remove(_ coordinator: (any CoordinatorProtocol)?) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
