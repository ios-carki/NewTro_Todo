import UIKit
import SwiftUI

final class MainCoordinator: CoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [any CoordinatorProtocol] = []

    private let diContainer: DIContainer
    private var mainVM: MainViewModel?
    private var calendarVM: CalendarViewModel?
    private var settingsVM: SettingsViewModel?

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    @MainActor func start() {
        let mainVM = diContainer.makeMainViewModel()
        let calendarVM = diContainer.makeCalendarViewModel()
        let settingsVM = diContainer.makeSettingsViewModel()

        settingsVM.onResetComplete = { [weak self] in self?.restartApp() }

        self.mainVM = mainVM
        self.calendarVM = calendarVM
        self.settingsVM = settingsVM

        let container = RootTabContainerView(
            mainVM: mainVM,
            calendarVM: calendarVM,
            settingsVM: settingsVM
        )
        let hostingVC = UIHostingController(rootView: container)
        navigationController.setViewControllers([hostingVC], animated: false)
    }

    private func restartApp() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let sceneDelegate = windowScene?.delegate as? SceneDelegate
        sceneDelegate?.restartApp()
    }
}
