import UIKit
import SwiftUI

final class MainCoordinator: CoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [any CoordinatorProtocol] = []

    private let diContainer: DIContainer

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    @MainActor func start() {
        let viewModel = diContainer.makeMainViewModel()
        let view = MainView(
            viewModel: viewModel,
            onCalendarTapped: { [weak self] in self?.showCalendar() },
            onSettingsTapped: { [weak self] in self?.showSettings() }
        )
        let hostingVC = UIHostingController(rootView: view)
        hostingVC.navigationItem.largeTitleDisplayMode = .never
        navigationController.setViewControllers([hostingVC], animated: false)
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
