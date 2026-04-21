import UIKit

protocol CoordinatorProtocol: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [any CoordinatorProtocol] { get set }
    func start()
}
