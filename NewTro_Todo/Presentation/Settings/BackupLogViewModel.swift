import Foundation
import Combine

@MainActor
final class BackupLogViewModel: ObservableObject {

    enum Filter: Equatable, Hashable {
        case all
        case today
        case last7Days
        case last30Days
        case custom(from: Date, to: Date)

        var titleKey: String {
            switch self {
            case .all:        return "전체"
            case .today:      return "오늘"
            case .last7Days:  return "7일"
            case .last30Days: return "30일"
            case .custom:     return "기간"
            }
        }

        var isCustom: Bool {
            if case .custom = self { return true } else { return false }
        }
    }

    enum SortOrder: Equatable {
        case newest
        case oldest

        var titleKey: String {
            self == .newest ? "최신순" : "오래된 순"
        }
    }

    struct Section: Identifiable {
        let id: String          // yyyy-MM-dd
        let date: Date          // 해당 날짜 00:00
        let entries: [BackupLogEntry]
    }

    @Published private(set) var allLogs: [BackupLogEntry] = []
    @Published var filter: Filter = .all
    @Published var sortOrder: SortOrder = .newest
    @Published var showCustomRangePicker: Bool = false

    // 커스텀 기간 선택용 임시 상태 (시트에서만 편집, 확정 시 filter로 반영)
    @Published var customFrom: Date = Calendar.current.startOfDay(for: Date())
    @Published var customTo: Date = Date()

    private let fetchUseCase: any FetchBackupLogsUseCaseProtocol
    private let clearUseCase: any ClearBackupLogsUseCaseProtocol

    init(
        fetchBackupLogsUseCase: any FetchBackupLogsUseCaseProtocol,
        clearBackupLogsUseCase: any ClearBackupLogsUseCaseProtocol
    ) {
        self.fetchUseCase = fetchBackupLogsUseCase
        self.clearUseCase = clearBackupLogsUseCase
    }

    func onAppear() {
        Task { await reload() }
    }

    func reload() async {
        allLogs = await fetchUseCase.execute()
    }

    func clearAll() {
        Task {
            await clearUseCase.execute()
            await reload()
        }
    }

    func selectFilter(_ filter: Filter) {
        if case .custom = filter {
            // "기간" 탭: 시트 띄워서 범위 입력 받기
            let now = Date()
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
            customFrom = Calendar.current.startOfDay(for: weekAgo)
            customTo = now
            showCustomRangePicker = true
        } else {
            self.filter = filter
        }
    }

    func confirmCustomRange() {
        let cal = Calendar.current
        let from = cal.startOfDay(for: customFrom)
        // to 는 해당 일 23:59:59.999 까지 포함
        let to = cal.date(bySettingHour: 23, minute: 59, second: 59, of: customTo) ?? customTo
        filter = .custom(from: from, to: to)
        showCustomRangePicker = false
    }

    func cancelCustomRange() {
        showCustomRangePicker = false
    }

    func toggleSortOrder() {
        sortOrder = (sortOrder == .newest) ? .oldest : .newest
    }

    // MARK: - Derived

    var filteredLogs: [BackupLogEntry] {
        let cal = Calendar.current
        let now = Date()
        let range: (start: Date, end: Date)?
        switch filter {
        case .all:
            range = nil
        case .today:
            let start = cal.startOfDay(for: now)
            range = (start, now)
        case .last7Days:
            let start = cal.date(byAdding: .day, value: -7, to: now) ?? now
            range = (start, now)
        case .last30Days:
            let start = cal.date(byAdding: .day, value: -30, to: now) ?? now
            range = (start, now)
        case .custom(let from, let to):
            range = (from, to)
        }
        return allLogs.filter { entry in
            guard let range else { return true }
            return entry.createdAt >= range.start && entry.createdAt <= range.end
        }
    }

    var sections: [Section] {
        let cal = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let grouped: [String: [BackupLogEntry]] = Dictionary(grouping: filteredLogs) { entry in
            formatter.string(from: cal.startOfDay(for: entry.createdAt))
        }
        let sortKeyAsc = sortOrder == .oldest
        let result: [Section] = grouped.map { key, entries in
            let dayStart = cal.startOfDay(
                for: formatter.date(from: key) ?? Date()
            )
            // 섹션 내부는 정렬 옵션에 맞춰 정렬
            let sorted = entries.sorted { a, b in
                sortKeyAsc ? a.createdAt < b.createdAt : a.createdAt > b.createdAt
            }
            return Section(id: key, date: dayStart, entries: sorted)
        }
        return result.sorted { a, b in
            sortKeyAsc ? a.date < b.date : a.date > b.date
        }
    }

    var isEmpty: Bool { filteredLogs.isEmpty }

    var totalCount: Int { allLogs.count }
}
