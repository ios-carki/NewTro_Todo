import UIKit

final class OnboardingCoordinator: CoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [any CoordinatorProtocol] = []
    var onFinished: (() -> Void)?

    private let diContainer: DIContainer

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        let vc = PageViewController()
        vc.onFinished = { [weak self] in self?.finish() }
        navigationController.setViewControllers([vc], animated: false)
    }

    private func finish() {
        UserDefaults.standard.set(true, forKey: "oldUser")
        onFinished?()
    }
}
