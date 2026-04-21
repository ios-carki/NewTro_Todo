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

        if UserDefaults.standard.bool(forKey: "oldUser") {
            showMain()
        } else {
            showOnboarding()
        }
    }

    private func showOnboarding() {
        let coordinator = OnboardingCoordinator(
            navigationController: navigationController,
            diContainer: diContainer
        )
        coordinator.onFinished = { [weak self, weak coordinator] in
            self?.childCoordinators.removeAll { $0 === coordinator }
            self?.showMain()
        }
        childCoordinators.append(coordinator)
        coordinator.start()
    }

    private func showMain() {
        let coordinator = MainCoordinator(
            navigationController: navigationController,
            diContainer: diContainer
        )
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}
