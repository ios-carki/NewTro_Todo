import UIKit
import SwiftUI

final class MainCoordinator: CoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [any CoordinatorProtocol] = []

    private let diContainer: DIContainer
    private var mainViewModel: MainViewModel?

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    @MainActor func start() {
        let viewModel = diContainer.makeMainViewModel()
        mainViewModel = viewModel

        let view = MainView(
            viewModel: viewModel,
            onCalendarTapped: { [weak self] in self?.showCalendar() },
            onSettingsTapped: { [weak self] in self?.showSettings() }
        )
        let hostingVC = UIHostingController(rootView: view)
        hostingVC.navigationItem.largeTitleDisplayMode = .never
        navigationController.setViewControllers([hostingVC], animated: false)
    }

    @MainActor func showCalendar() {
        let coordinator = CalendarCoordinator(
            navigationController: navigationController,
            diContainer: diContainer,
            initialDate: mainViewModel?.selectedDate ?? Date()
        )
        coordinator.onDateSelected = { [weak self] date in
            self?.mainViewModel?.selectedDate = date
            self?.mainViewModel?.loadTodos()
        }
        childCoordinators.append(coordinator)
        coordinator.start()
    }

    func showSettings() {
        let vc = SettingViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}
