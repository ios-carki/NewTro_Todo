import UIKit
import SwiftUI

final class WelcomeCoordinator: CoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [any CoordinatorProtocol] = []
    var onFinished: (() -> Void)?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let view = WelcomeView { [weak self] in
            self?.finish()
        }
        let vc = UIHostingController(rootView: view)
        vc.navigationItem.hidesBackButton = true
        navigationController.setViewControllers([vc], animated: false)
    }

    private func finish() {
        // 이 버전에서 본 것으로 기록 — 이후 일반 실행에서 스킵
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0.0"
        UserDefaults.standard.set(version, forKey: "welcomeSeenVersion")
        onFinished?()
    }
}
