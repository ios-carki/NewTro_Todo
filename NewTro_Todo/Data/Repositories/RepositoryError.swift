import Foundation

enum RepositoryError: LocalizedError {
    case notFound
    case invalidId
    case insufficientFunds

    var errorDescription: String? {
        switch self {
        case .notFound:             return "데이터를 찾을 수 없습니다.".localized()
        case .invalidId:            return "잘못된 데이터 식별자입니다.".localized()
        case .insufficientFunds:    return "잔액이 부족합니다.".localized()
        }
    }
}
