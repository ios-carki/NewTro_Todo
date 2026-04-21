import UIKit
import SwiftUI

final class SplashCoordinator: CoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [any CoordinatorProtocol] = []
    var onFinished: (() -> Void)?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let splashView = SplashView { [weak self] in
            self?.finish()
        }
        let vc = UIHostingController(rootView: splashView)
        vc.navigationItem.hidesBackButton = true
        navigationController.setViewControllers([vc], animated: false)
    }

    private func finish() {
        onFinished?()
    }
}
