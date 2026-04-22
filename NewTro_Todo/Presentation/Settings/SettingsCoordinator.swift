import UIKit
import SwiftUI

final class SettingsCoordinator: CoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [any CoordinatorProtocol] = []

    private let diContainer: DIContainer

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    @MainActor func start() {
        let viewModel = SettingsViewModel(
            clearAllDataUseCase: diContainer.makeClearAllDataUseCase()
        )
        viewModel.onResetComplete = { [weak self] in
            self?.restartApp()
        }

        let view = SettingsView(viewModel: viewModel) { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        let vc = UIHostingController(rootView: view)
        vc.navigationItem.hidesBackButton = true
        navigationController.pushViewController(vc, animated: true)
    }

    private func restartApp() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let sceneDelegate = windowScene?.delegate as? SceneDelegate
        sceneDelegate?.restartApp()
    }
}
