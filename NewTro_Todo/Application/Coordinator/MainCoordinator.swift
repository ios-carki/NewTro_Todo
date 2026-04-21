import UIKit

final class MainCoordinator: CoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [any CoordinatorProtocol] = []

    private let diContainer: DIContainer

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        let vc = MainViewController()
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    func showCalendar() {
        let vc = CalendarViewController()
        navigationController.pushViewController(vc, animated: true)
    }

    func showSettings() {
        let vc = SettingViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}
