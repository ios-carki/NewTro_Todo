import Foundation

@MainActor
final class IncompleteListViewModel: ObservableObject {

    enum SortType: String, CaseIterable, Identifiable {
        case newest, oldest
        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .newest: return "최신순"
            case .oldest: return "오래된순"
            }
        }
    }

    @Published private(set) var todos: [TodoEntity] = []
    @Published var sortType: SortType = .newest

    private let fetchUseCase: any FetchIncompleteTodosUseCaseProtocol

    init(fetchUseCase: any FetchIncompleteTodosUseCaseProtocol) {
        self.fetchUseCase = fetchUseCase
    }

    var displayedTodos: [TodoEntity] {
        switch sortType {
        case .newest: return todos.sorted { $0.createdAt > $1.createdAt }
        case .oldest: return todos.sorted { $0.createdAt < $1.createdAt }
        }
    }

    func load() {
        Task {
            if let list = try? await fetchUseCase.execute() {
                todos = list
            }
        }
    }
}
