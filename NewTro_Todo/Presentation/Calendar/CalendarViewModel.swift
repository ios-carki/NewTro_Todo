import Foundation
import Combine

struct DayInfo {
    var total: Int = 0
    var done: Int  = 0
}

@MainActor
final class CalendarViewModel: ObservableObject {

    // MARK: - State
    @Published var viewYear: Int
    @Published var viewMonth: Int
    @Published var todosByDay: [String: DayInfo] = [:]   // key: "dd" (zero-padded)

    var onDateSelected: ((Date) -> Void)?

    private let fetchByMonthUseCase: any FetchTodosByMonthUseCaseProtocol

    init(
        initialDate: Date = Date(),
        fetchByMonthUseCase: any FetchTodosByMonthUseCaseProtocol
    ) {
        let cal = Calendar.current
        self.viewYear  = cal.component(.year,  from: initialDate)
        self.viewMonth = cal.component(.month, from: initialDate)
        self.fetchByMonthUseCase = fetchByMonthUseCase
    }

    // MARK: - Grid
    var cells: [Int?] {
        var comps = DateComponents()
        comps.year  = viewYear
        comps.month = viewMonth
        comps.day   = 1
        guard let first = Calendar.current.date(from: comps) else { return [] }
        let weekday   = Calendar.current.component(.weekday, from: first) - 1  // 0=Sun
        let daysCount = Calendar.current.range(of: .day, in: .month, for: first)!.count
        return Array(repeating: nil, count: weekday) + (1...daysCount).map { Optional($0) }
    }

    var totalDoneThisMonth: Int { todosByDay.values.reduce(0) { $0 + $1.done } }

    var monthTitle: String { String(format: "%d.%02d", viewYear, viewMonth) }

    // MARK: - Navigation
    func prevMonth() {
        if viewMonth == 1 { viewYear -= 1; viewMonth = 12 }
        else { viewMonth -= 1 }
        Task { await loadMonth() }
    }

    func nextMonth() {
        if viewMonth == 12 { viewYear += 1; viewMonth = 1 }
        else { viewMonth += 1 }
        Task { await loadMonth() }
    }

    // MARK: - Date Selection
    func selectDay(_ day: Int) {
        var comps = DateComponents()
        comps.year  = viewYear
        comps.month = viewMonth
        comps.day   = day
        guard let date = Calendar.current.date(from: comps) else { return }
        onDateSelected?(date)
    }

    // MARK: - Load
    func loadMonth() async {
        do {
            let todos = try await fetchByMonthUseCase.execute(year: viewYear, month: viewMonth)
            var map: [String: DayInfo] = [:]
            let formatter = DateFormatter()
            formatter.locale    = Locale.current
            formatter.timeZone  = TimeZone.current
            formatter.dateFormat = "yyyy년 MM월 dd일"
            for todo in todos {
                if let date = formatter.date(from: todo.targetDate.description) {
                    // targetDate is a Date — format to get day component
                    let d = Calendar.current.component(.day, from: todo.targetDate)
                    let key = String(format: "%02d", d)
                    var info = map[key] ?? DayInfo()
                    info.total += 1
                    if todo.isCompleted { info.done += 1 }
                    map[key] = info
                } else {
                    // Use targetDate directly
                    let d = Calendar.current.component(.day, from: todo.targetDate)
                    let key = String(format: "%02d", d)
                    var info = map[key] ?? DayInfo()
                    info.total += 1
                    if todo.isCompleted { info.done += 1 }
                    map[key] = info
                }
            }
            todosByDay = map
        } catch {
            // 캘린더는 데이터 로드 실패 시 빈 상태로 표시
            todosByDay = [:]
        }
    }

    // MARK: - Helpers
    func isToday(day: Int) -> Bool {
        let cal = Calendar.current
        let now = Date()
        return cal.component(.year,  from: now) == viewYear &&
               cal.component(.month, from: now) == viewMonth &&
               cal.component(.day,   from: now) == day
    }

    func weekday(day: Int) -> Int {
        var comps = DateComponents()
        comps.year  = viewYear
        comps.month = viewMonth
        comps.day   = day
        guard let date = Calendar.current.date(from: comps) else { return 0 }
        return Calendar.current.component(.weekday, from: date) - 1  // 0=Sun, 6=Sat
    }
}
