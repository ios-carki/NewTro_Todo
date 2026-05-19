import Foundation
import Combine

@MainActor
final class StatsViewModel: ObservableObject {

    // MARK: - State
    @Published var stats: StatsEntity = StatsEntity()
    @Published var weeklyData: [Int] = Array(repeating: 0, count: 7)
    @Published var weeklyLabels: [String] = []

    // MARK: - UseCases
    private let fetchStatsUseCase: any FetchStatsUseCaseProtocol
    private let fetchWeeklyUseCase: any FetchWeeklyCompletionsUseCaseProtocol

    init(
        fetchStatsUseCase: any FetchStatsUseCaseProtocol,
        fetchWeeklyUseCase: any FetchWeeklyCompletionsUseCaseProtocol
    ) {
        self.fetchStatsUseCase = fetchStatsUseCase
        self.fetchWeeklyUseCase = fetchWeeklyUseCase
        buildWeeklyLabels()
    }

    // MARK: - Load
    func loadStats() {
        Task {
            stats = await fetchStatsUseCase.execute()
            if let data = try? await fetchWeeklyUseCase.execute() {
                weeklyData = data
            }
        }
    }

    // MARK: - Computed
    var weeklyMax: Int { max(weeklyData.max() ?? 1, 1) }

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
