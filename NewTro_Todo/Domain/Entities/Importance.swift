import Foundation

enum Importance: Int, Hashable {
    case none = 0
    case high = 1
    case medium = 2

    var coinValue: Int {
        switch self {
        case .none:   return 1
        case .medium: return 2
        case .high:   return 3
        }
    }
}
