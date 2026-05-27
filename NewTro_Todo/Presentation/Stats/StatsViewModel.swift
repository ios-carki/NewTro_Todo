import Foundation
import Combine

@MainActor
final class StatsViewModel: ObservableObject {

    // MARK: - State
    @Published var stats: StatsEntity = StatsEntity()
    @Published var weeklyData: [WeeklyDayCounts] = Array(
        repeating: WeeklyDayCounts(completed: 0, incomplete: 0), count: 7
    )
    @Published var weeklyLabels: [String] = []
    @Published private(set) var completedCount: Int = 0
    @Published private(set) var totalCount: Int = 0
    /// "이미 지난 날 중 완료 못 한 Todo" 개수. 오늘/미래는 제외.
    /// 루틴이 미래로 미리 만들어둔 Todo 가 카운트에 섞이지 않게 별도 쿼리로 가져온다.
    @Published private(set) var incompleteCount: Int = 0

    // MARK: - UseCases
    private let fetchStatsUseCase: any FetchStatsUseCaseProtocol
    private let fetchWeeklyUseCase: any FetchWeeklyTodoCountsUseCaseProtocol
    private let fetchTodoCountsUseCase: any FetchTodoCountsUseCaseProtocol
    private let fetchPastIncompleteCountUseCase: any FetchPastIncompleteCountUseCaseProtocol

    init(
        fetchStatsUseCase: any FetchStatsUseCaseProtocol,
        fetchWeeklyUseCase: any FetchWeeklyTodoCountsUseCaseProtocol,
        fetchTodoCountsUseCase: any FetchTodoCountsUseCaseProtocol,
        fetchPastIncompleteCountUseCase: any FetchPastIncompleteCountUseCaseProtocol
    ) {
        self.fetchStatsUseCase = fetchStatsUseCase
        self.fetchWeeklyUseCase = fetchWeeklyUseCase
        self.fetchTodoCountsUseCase = fetchTodoCountsUseCase
        self.fetchPastIncompleteCountUseCase = fetchPastIncompleteCountUseCase
        buildWeeklyLabels()
    }

    // MARK: - Load
    func loadStats() {
        Task {
            stats = await fetchStatsUseCase.execute()
            if let data = try? await fetchWeeklyUseCase.execute() {
                weeklyData = data
            }
            if let counts = try? await fetchTodoCountsUseCase.execute() {
                completedCount = counts.completed
                totalCount = counts.total
            }
            if let past = try? await fetchPastIncompleteCountUseCase.execute() {
                incompleteCount = past
            }
        }
    }

    // MARK: - Computed
    /// 7일 칸 중 가장 큰 (완료 또는 미완료) 값. 막대 높이 비율 계산용. 0 이어도 분모 1 보장.
    var weeklyMax: Int {
        let m = weeklyData.flatMap { [$0.completed, $0.incomplete] }.max() ?? 1
        return max(m, 1)
    }

    func perfectDays(for month: Date) -> Set<Int> {
        let cal = Calendar.current
        let y = cal.component(.year,  from: month)
        let m = cal.component(.month, from: month)
        let prefix = String(format: "%04d-%02d-", y, m)
        return Set(
            stats.perfectDayDateStrings
                .filter { $0.hasPrefix(prefix) }
                .compactMap { Int($0.dropFirst(prefix.count)) }
        )
    }

    func monthLabel(for date: Date) -> String {
        let cal = Calendar.current
        let y = cal.component(.year,  from: date)
        let m = cal.component(.month, from: date)
        return String(format: "%04d.%02d", y, m)
    }

    func isCurrentMonth(_ date: Date) -> Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month)
    }

    private func buildWeeklyLabels() {
        let cal = Calendar.current
        weeklyLabels = (0..<7).map { i in
            let date = cal.date(byAdding: .day, value: -(6 - i), to: Date()) ?? Date()
            let m = cal.component(.month, from: date)
            let d = cal.component(.day, from: date)
            return "\(m)/\(d)"
        }
    }
}
