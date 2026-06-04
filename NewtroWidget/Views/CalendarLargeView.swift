import SwiftUI
import WidgetKit

// Large 위젯 ① — 이번 달 달력. 앱 달력과 동일하게 일자별 Todo 개수를 ▣ 로,
// 메모 있는 날은 우상단 코너 플래그로 표시. 오늘 강조. 월 이동 없음(오늘의 년·월만 상단).
struct CalendarLargeView: View {
    let data: TodayWidgetData

    private var yearMonthText: String {
        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate("yMMMM")  // ko "2026년 3월" / en "March 2026" / ja·zh "2026年3月"
        return f.string(from: data.date)
    }

    private var weekdaySymbols: [String] {
        let s = Calendar.current.veryShortStandaloneWeekdaySymbols
        return s.count == 7 ? s : ["S", "M", "T", "W", "T", "F", "S"]
    }

    // 선행 빈칸(offset) + 1...말일
    private var days: [Int?] {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: data.date)
        guard let first = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: first) else { return [] }
        let offset = cal.component(.weekday, from: first) - 1
        return Array(repeating: nil, count: offset) + range.map { Optional($0) }
    }

    var body: some View {
        VStack(spacing: 5) {
            Text(yearMonthText)
                .font(.galBold17())
                .foregroundColor(.ink)

            HStack(spacing: 3) {
                ForEach(0..<7, id: \.self) { i in
                    Text(weekdaySymbols[i])
                        .font(.galBold10())
                        .foregroundColor(weekdayColor(i))
                        .frame(maxWidth: .infinity)
                }
            }

            let cols = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)
            LazyVGrid(columns: cols, spacing: 3) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                    if let day {
                        dayCell(day)
                    } else {
                        Color.clear.frame(height: 38)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func weekdayColor(_ index: Int) -> Color {
        switch index {
        case 0:  return .redDk                  // 일
        case 6:  return Color(hex: "#3A7FC1")   // 토
        default: return .ink
        }
    }

    @ViewBuilder
    private func dayCell(_ day: Int) -> some View {
        let cell = data.monthCells[day] ?? WidgetDayCell()
        let isToday = (day == data.day)

        ZStack {
            Rectangle()
                .fill(isToday ? Color.sun.opacity(0.55) : Color.white.opacity(0.45))
                .overlay(Rectangle().stroke(Color.ink.opacity(isToday ? 1 : 0.25),
                                            lineWidth: isToday ? 2 : 1))

            VStack(spacing: 2) {
                Text(String(format: "%02d", day))
                    .font(.pressStart9())
                    .foregroundColor(.ink)
                todoSquares(cell.todoCount)
            }

            if cell.hasMemo {
                Rectangle()
                    .fill(Color.peachDk)
                    .frame(width: 6, height: 6)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(2)
            }
        }
        .frame(height: 38)
    }

    // 0개: 비움 / 1·2·3개: ▣ 그만큼 / 4개 이상: ▣▣▣ +N
    @ViewBuilder
    private func todoSquares(_ count: Int) -> some View {
        if count > 0 {
            HStack(spacing: 1.5) {
                ForEach(0..<min(count, 3), id: \.self) { _ in
                    Rectangle().fill(Color.ink).frame(width: 4, height: 4)
                }
                if count > 3 {
                    Text(count - 3 > 99 ? "99+" : "+\(count - 3)")
                        .font(.pressStart8())
                        .foregroundColor(.ink)
                }
            }
            .frame(height: 5)
        } else {
            Color.clear.frame(height: 5)
        }
    }
}
