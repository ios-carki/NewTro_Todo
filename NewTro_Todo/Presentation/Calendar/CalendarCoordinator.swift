import UIKit
import SwiftUI

final class CalendarCoordinator: CoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [any CoordinatorProtocol] = []

    private let diContainer: DIContainer
    private let initialDate: Date
    var onDateSelected: ((Date) -> Void)?

    init(
        navigationController: UINavigationController,
        diContainer: DIContainer,
        initialDate: Date = Date()
    ) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        self.initialDate = initialDate
    }

    @MainActor func start() {
        let viewModel = CalendarViewModel(
            initialDate: initialDate,
            fetchByMonthUseCase: diContainer.makeFetchTodosByMonthUseCase()
        )
        viewModel.onDateSelected = { [weak self] date in
            self?.onDateSelected?(date)
        }

        let view = CalendarView(viewModel: viewModel) { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        let vc = UIHostingController(rootView: view)
        vc.navigationItem.hidesBackButton = true
        navigationController.pushViewController(vc, animated: true)
    }
}
