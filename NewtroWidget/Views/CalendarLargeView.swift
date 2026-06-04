import SwiftUI
import WidgetKit

// Large 위젯 ① — 이번 달 달력. 앱 달력과 동일하게 일자별 Todo 개수를 ▣ 로 표시,
// 메모 있는 날은 코너 플래그. 오늘=초록 / Todo 모두 완료한 날=노랑 / 빈칸=회색.
// 매 행 7칸 완성(선행·후행 빈칸 회색). 셀을 크게 키워 위젯 높이를 모두 사용.
struct CalendarLargeView: View {
    let data: TodayWidgetData

    private var yearMonthText: String {
        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate("yMMMM")  // ko "2026년 6월" / en "June 2026" / ja·zh "2026年6月"
        return f.string(from: data.date)
    }

    private var weekdaySymbols: [String] {
        let s = Calendar.current.veryShortStandaloneWeekdaySymbols
        return s.count == 7 ? s : ["S", "M", "T", "W", "T", "F", "S"]
    }

    /// 선행 빈칸 + 1...말일 + 후행 빈칸(마지막 주 7칸 완성). nil = 빈칸.
    private var cells: [Int?] {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: data.date)
        guard let first = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: first) else { return [] }
        let offset = cal.component(.weekday, from: first) - 1
        var arr: [Int?] = Array(repeating: nil, count: offset) + range.map { Optional($0) }
        let rem = arr.count % 7
        if rem != 0 { arr += Array(repeating: nil, count: 7 - rem) }
        return arr
    }

    private var rows: Int { max(1, cells.count / 7) }

    var body: some View {
        VStack(spacing: 6) {
            Text(yearMonthText)
                .font(.galBold17())
                .foregroundColor(.ink)

            weekdayHeader

            GeometryReader { geo in
                let gaps = CGFloat(rows - 1) * 3
                let rowH = max(28, (geo.size.height - gaps) / CGFloat(rows))
                VStack(spacing: 3) {
                    ForEach(0..<rows, id: \.self) { r in
                        HStack(spacing: 3) {
                            ForEach(0..<7, id: \.self) { c in
                                dayCell(cells[r * 7 + c], height: rowH)
                            }
                        }
                    }
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: 요일 헤더 (테두리 + 배경색)
    private var weekdayHeader: some View {
        HStack(spacing: 3) {
            ForEach(0..<7, id: \.self) { i in
                Text(weekdaySymbols[i])
                    .font(.galBold10())
                    .foregroundColor(weekdayColor(i))
                    .frame(maxWidth: .infinity)
                    .frame(height: 20)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))
            }
        }
    }

    private func weekdayColor(_ index: Int) -> Color {
        switch index {
        case 0:  return .redDk                  // 일
        case 6:  return Color(hex: "#3A7FC1")   // 토
        default: return .ink
        }
    }

    // MARK: 일자 셀
    @ViewBuilder
    private func dayCell(_ day: Int?, height: CGFloat) -> some View {
        if let day {
            let cell = data.monthCells[day] ?? WidgetDayCell()
            let isToday = (day == data.day)
            let bg: Color = isToday      ? Color(hex: "#A7E08A")   // 오늘 - 초록 계열
                          : cell.allDone ? Color(hex: "#FFE08A")   // 모두 완료 - 노랑
                          : .white

            ZStack {
                Rectangle()
                    .fill(bg)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: isToday ? 2 : 1))

                VStack(spacing: 2) {
                    Text(String(format: "%02d", day))
                        .font(.pressStart10())
                        .foregroundColor(.ink)
                    todoSquares(cell.todoCount)
                    Spacer(minLength: 0)
                }
                .padding(.top, 5)

                if cell.hasMemo {
                    Rectangle()
                        .fill(Color.peachDk)
                        .frame(width: 7, height: 7)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(3)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
        } else {
            // 빈칸 - 회색
            Rectangle()
                .fill(Color.shade.opacity(0.18))
                .overlay(Rectangle().stroke(Color.ink.opacity(0.2), lineWidth: 1))
                .frame(maxWidth: .infinity)
                .frame(height: height)
        }
    }

    // 0개: 비움 / 1·2·3개: ▣ / 4개 이상: ▣▣▣ +N
    @ViewBuilder
    private func todoSquares(_ count: Int) -> some View {
        if count > 0 {
            HStack(spacing: 1.5) {
                ForEach(0..<min(count, 3), id: \.self) { _ in
                    Rectangle().fill(Color.ink).frame(width: 5, height: 5)
                }
                if count > 3 {
                    Text(count - 3 > 99 ? "99+" : "+\(count - 3)")
                        .font(.pressStart8())
                        .foregroundColor(.ink)
                }
            }
        }
    }
}
