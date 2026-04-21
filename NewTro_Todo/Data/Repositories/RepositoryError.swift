import Foundation

enum RepositoryError: LocalizedError {
    case notFound
    case invalidId

    var errorDescription: String? {
        switch self {
        case .notFound:     return "데이터를 찾을 수 없습니다."
        case .invalidId:    return "잘못된 데이터 식별자입니다."
        }
    }
}
