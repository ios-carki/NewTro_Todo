import UIKit
import SwiftUI

final class MainCoordinator: CoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [any CoordinatorProtocol] = []

    private let diContainer: DIContainer
    private var mainVM: MainViewModel?
    private var memoVM: MemoViewModel?
    private var statsVM: StatsViewModel?
    private var settingsVM: SettingsViewModel?

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    @MainActor func start() {
        // 인스턴스 단위 백버튼 chevron 틴트 고정 (UINavigationBar.appearance만으로는 SwiftUI 푸시 시 시스템 파란색이 그대로 보임)
        navigationController.navigationBar.tintColor = .inkC

        let mainVM     = diContainer.makeMainViewModel()
        let memoVM     = diContainer.makeMemoViewModel()
        let statsVM    = diContainer.makeStatsViewModel()
        let settingsVM = diContainer.makeSettingsViewModel()

        settingsVM.onResetComplete = { [weak self] in self?.restartApp() }

        self.mainVM     = mainVM
        self.memoVM     = memoVM
        self.statsVM    = statsVM
        self.settingsVM = settingsVM

        let container = RootTabContainerView(
            mainVM: mainVM,
            memoVM: memoVM,
            statsVM: statsVM,
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
