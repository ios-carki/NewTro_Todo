import SwiftUI

// 통계 탭 전용 달력. 메인의 PixelCalendarPicker 와 외형을 통일하되,
// 메모 fold·todo squares 마커는 빼고 "투두 모두 완료" 도장(별)을 표시한다.
struct PerfectStampCalendar: View {
    @Binding var month: Date
    let perfectDays: Set<Int>
    let monthLabel: String
    let isCurrentMonth: Bool

    var body: some View {
        VStack(spacing: 0) {
            monthNavPanel
            calendarGrid
                .padding(.top, 10)
        }
    }

    private var monthNavPanel: some View {
        HStack(spacing: 0) {
            Button { prevMonth() } label: {
                Text("◀")
                    .font(.pressStart14())
                    .foregroundColor(.ink)
                    .frame(width: 50, height: 46)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            }

            Text(headerTitle)
                .font(.pressStart14())
                .foregroundColor(.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color.panel)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))

            Button { nextMonth() } label: {
                Text("▶")
                    .font(.pressStart14())
                    .foregroundColor(isCurrentMonth ? .shade.opacity(0.3) : .ink)
                    .frame(width: 50, height: 46)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            }
            .disabled(isCurrentMonth)
        }
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
    }

    private var calendarGrid: some View {
        PixelPanel(bg: .white, padding: 6) {
            VStack(spacing: 6) {
                weekdayHeader
                dayGrid
                completionLabel
            }
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { i in
                Text(perfectWeekdays[i])
                    .font(.galBold14())
                    .foregroundColor(i == 0 ? .pixelRed : i == 6 ? .sky : .shade)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
        }
    }

    private var dayGrid: some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)
        let todayDay: Int? = isCurrentMonth ? Calendar.current.component(.day, from: Date()) : nil
        return LazyVGrid(columns: cols, spacing: 3) {
            ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                if let d = day {
                    PerfectDayCell(
                        day: d,
                        isPerfect: perfectDays.contains(d),
                        isToday: d == todayDay,
                        weekday: weekdayOf(day: d)
                    )
                } else {
                    Color.clear.frame(height: 50)
                }
            }
        }
        // 월별 주 수 차이로 높이가 흔들리지 않도록 6주(50pt 셀 × 6 + spacing 3 × 5) 고정.
        .frame(height: 50 * 6 + 3 * 5)
    }

    // 달력 하단에 "yyyy.mm → 하루 목표 달성 N회"
    private var completionLabel: some View {
        HStack(spacing: 6) {
            Text(monthLabel)
                .font(.pressStart9())
                .foregroundColor(.ink)
            Text("→")
                .font(.pressStart9())
                .foregroundColor(.shade)
            Text("하루 목표 달성 %d회".localized(with: perfectDays.count))
                .font(.pressStart9())
                .foregroundColor(perfectDays.isEmpty ? .shade.opacity(0.5) : .sunDk)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
    }

    // MARK: - Helpers
    private var headerTitle: String {
        let cal = Calendar.current
        let y = cal.component(.year, from: month)
        let m = cal.component(.month, from: month)
        return String(format: "%d.%02d", y, m)
    }

    private var cells: [Int?] {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.year  = cal.component(.year,  from: month)
        comps.month = cal.component(.month, from: month)
        comps.day   = 1
        guard let first = cal.date(from: comps),
              let count = cal.range(of: .day, in: .month, for: first)?.count else { return [] }
        let offset = cal.component(.weekday, from: first) - 1
        let base: [Int?] = Array(repeating: nil, count: offset) + (1...count).map { Optional($0) }
        // 월별 주 수 차이로 인한 그리드 높이 흔들림 방지: 항상 6주(42칸)로 패딩
        let total = 42
        return base.count >= total ? base : base + Array(repeating: nil, count: total - base.count)
    }

    private func weekdayOf(day: Int) -> Int {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.year  = cal.component(.year,  from: month)
        comps.month = cal.component(.month, from: month)
        comps.day   = day
        guard let date = cal.date(from: comps) else { return 0 }
        return cal.component(.weekday, from: date) - 1
    }

    private func prevMonth() {
        month = Calendar.current.date(byAdding: .month, value: -1, to: month) ?? month
    }

    private func nextMonth() {
        let next = Calendar.current.date(byAdding: .month, value: 1, to: month) ?? month
        // 현재 달 이후는 잠금
        if Calendar.current.compare(next, to: Date(), toGranularity: .month) == .orderedDescending { return }
        month = next
    }
}

private var perfectWeekdays: [String] {
    var cal = Calendar.current
    cal.locale = Locale.current
    let symbols = cal.veryShortStandaloneWeekdaySymbols
    return symbols.count == 7 ? symbols : ["S", "M", "T", "W", "T", "F", "S"]
}

private struct PerfectDayCell: View {
    let day: Int
    let isPerfect: Bool
    let isToday: Bool
    let weekday: Int

    private var bgColor: Color {
        if isPerfect { return Color.sun.opacity(0.4) }
        if isToday { return Color(hex: "#FFD6E0").opacity(0.5) }
        return .white
    }

    private var borderColor: Color {
        if isPerfect { return .sunDk }
        if isToday { return .pixelPink }
        return .ink
    }

    private var borderWidth: CGFloat { (isPerfect || isToday) ? 2.5 : 2 }

    private var dayColor: Color {
        if isPerfect { return .ink }
        switch weekday {
        case 0: return .redDk
        case 6: return Color(hex: "#3A7FC1")
        default: return .ink
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(bgColor)
                .overlay(Rectangle().stroke(borderColor, lineWidth: borderWidth))
            Text(String(format: "%02d", day))
                .font(.pressStart10())
                .foregroundColor(dayColor)
        }
        .frame(height: 50)
    }
}
