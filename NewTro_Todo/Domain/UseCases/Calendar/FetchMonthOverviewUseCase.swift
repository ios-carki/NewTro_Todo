import Foundation

struct DayContent: OptionSet {
    let rawValue: Int
    static let todo = DayContent(rawValue: 1 << 0)
    static let memo = DayContent(rawValue: 1 << 1)
}

struct MonthOverview {
    let year: Int
    let month: Int
    let dayContent: [Int: DayContent]
}

protocol FetchMonthOverviewUseCaseProtocol {
    func execute(year: Int, month: Int) async throws -> MonthOverview
}

final class FetchMonthOverviewUseCase: FetchMonthOverviewUseCaseProtocol {
    private let todoRepository: any TodoRepositoryProtocol
    private let memoRepository: any MemoRepositoryProtocol

    init(
        todoRepository: any TodoRepositoryProtocol,
        memoRepository: any MemoRepositoryProtocol
    ) {
        self.todoRepository = todoRepository
        self.memoRepository = memoRepository
    }

    func execute(year: Int, month: Int) async throws -> MonthOverview {
        let cal = Calendar.current
        var startComps = DateComponents()
        startComps.year = year
        startComps.month = month
        startComps.day = 1
        guard let start = cal.date(from: startComps),
              let end = cal.date(byAdding: .month, value: 1, to: start) else {
            return MonthOverview(year: year, month: month, dayContent: [:])
        }

        async let todosTask = todoRepository.fetchTodos(year: year, month: month)
        async let memosTask = memoRepository.fetchMemos(from: start, to: end)

        let (todos, memos) = try await (todosTask, memosTask)

        var map: [Int: DayContent] = [:]
        for todo in todos {
            let day = cal.component(.day, from: todo.targetDate)
            map[day, default: []].insert(.todo)
        }
        for memo in memos {
            let day = cal.component(.day, from: memo.targetDate)
            map[day, default: []].insert(.memo)
        }
        return MonthOverview(year: year, month: month, dayContent: map)
    }
}
