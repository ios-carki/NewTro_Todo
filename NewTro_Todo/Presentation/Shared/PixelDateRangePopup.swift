import SwiftUI

// 메모/백업로그 기간 필터에 공통으로 쓰이는 단일 달력 popup.
// 첫 탭 = 시작, 두 번째 탭 = 끝(시작보다 앞이면 swap), 세 번째 탭부터 새 시작으로 리셋.
// 활성 단계는 시작/끝 라벨 하이라이트로 표시.
struct PixelDateRangePopup: View {
    enum Step { case from, to }

    let onApply: (Date, Date) -> Void
    let onClose: () -> Void

    @State private var pendingFrom: Date?
    @State private var pendingTo: Date?
    @State private var viewYear: Int
    @State private var viewMonth: Int

    init(
        initialFrom: Date,
        initialTo: Date,
        onApply: @escaping (Date, Date) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.onApply = onApply
        self.onClose = onClose
        _pendingFrom = State(initialValue: nil)
        _pendingTo = State(initialValue: nil)
        let cal = Calendar.current
        _viewYear  = State(initialValue: cal.component(.year, from: initialFrom))
        _viewMonth = State(initialValue: cal.component(.month, from: initialFrom))
    }

    private var activeStep: Step {
        if pendingFrom == nil { return .from }
        if pendingTo == nil { return .to }
        return .from
    }

    // dim 은 호스트(PopupCenter)가 그린다. 여기는 카드만 반환.
    var body: some View {
        popupCard
    }

    private var popupCard: some View {
        VStack(spacing: 0) {
            titleBar
            rangeLabelArea
            calendarSection
            applyButton
        }
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
    }

    private var titleBar: some View {
        HStack {
            Text("기간 설정")
                .font(.galBold13())
                .foregroundColor(.ink)
            Spacer()
            Button { onClose() } label: {
                Text("×")
                    .font(.pressStart10())
                    .foregroundColor(.ink)
                    .frame(width: 22, height: 22)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.sun)
        .overlay(
            Rectangle().fill(Color.ink).frame(height: 2),
            alignment: .bottom
        )
    }

    private var rangeLabelArea: some View {
        HStack(spacing: 0) {
            rangeLabel(title: "시작", date: pendingFrom, isActive: activeStep == .from)
            Spacer(minLength: 8)
            Text("~")
                .font(.galBold14())
                .foregroundColor(.ink)
            Spacer(minLength: 8)
            rangeLabel(title: "끝", date: pendingTo, isActive: activeStep == .to)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .overlay(
            Rectangle().fill(Color.ink.opacity(0.2)).frame(height: 1),
            alignment: .bottom
        )
    }

    private func rangeLabel(title: String, date: Date?, isActive: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.localized())
                .font(.galBold9())
                .foregroundColor(isActive ? .ink : .shade)
            Text(dateString(date))
                .font(.pressStart9())
                .foregroundColor(.ink)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(isActive ? Color.peach : Color.cream)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: isActive ? 2.5 : 1.5))
    }

    private func dateString(_ date: Date?) -> String {
        guard let d = date else { return "----.--.--" }
        let cal = Calendar.current
        return String(
            format: "%04d.%02d.%02d",
            cal.component(.year, from: d),
            cal.component(.month, from: d),
            cal.component(.day, from: d)
        )
    }

    private var calendarSection: some View {
        VStack(spacing: 8) {
            monthNav
            weekdayHeader
            dayGrid
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }

    private var monthNav: some View {
        HStack(spacing: 0) {
            Button { prevMonth() } label: {
                Text("◀")
                    .font(.pressStart12())
                    .foregroundColor(.ink)
                    .frame(width: 44, height: 34)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
            }
            Text(String(format: "%d.%02d", viewYear, viewMonth))
                .font(.pressStart12())
                .foregroundColor(.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background(Color.panel)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
            Button { nextMonth() } label: {
                Text("▶")
                    .font(.pressStart12())
                    .foregroundColor(isAtCurrentMonth ? .shade.opacity(0.4) : .ink)
                    .frame(width: 44, height: 34)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(
                        isAtCurrentMonth ? Color.shade.opacity(0.4) : Color.ink,
                        lineWidth: 1.5
                    ))
            }
            .disabled(isAtCurrentMonth)
        }
    }

    // 미래 월은 백업로그/메모 어디서 사용되든 의미가 없어서 현재 월에서 next 비활성.
    private var isAtCurrentMonth: Bool {
        let now = Date()
        let cal = Calendar.current
        return cal.component(.year, from: now) == viewYear
            && cal.component(.month, from: now) == viewMonth
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { i in
                Text(weekdayShort[i])
                    .font(.galBold11())
                    .foregroundColor(i == 0 ? .pixelRed : i == 6 ? .sky : .shade)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 2)
            }
        }
    }

    private var dayGrid: some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
        return LazyVGrid(columns: cols, spacing: 2) {
            ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                if let d = day {
                    PixelDateRangeDayCell(
                        day: d,
                        isStart: isStart(d),
                        isEnd: isEnd(d),
                        isInRange: isInRange(d),
                        weekday: weekdayOf(day: d),
                        onTap: { selectDay(d) }
                    )
                } else {
                    Color.clear.aspectRatio(1, contentMode: .fit)
                }
            }
        }
    }

    private var applyButton: some View {
        Button {
            guard let from = pendingFrom, let to = pendingTo else { return }
            onApply(from, to)
        } label: {
            Text("적용하기")
                .font(.galBold14())
                .foregroundColor(canApply ? .cream : .shade)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(canApply ? Color.peachDk : Color.panel)
                .overlay(Rectangle().stroke(
                    canApply ? Color.ink : Color.shade.opacity(0.4),
                    lineWidth: 2
                ))
        }
        .disabled(!canApply)
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }

    private var canApply: Bool {
        pendingFrom != nil && pendingTo != nil
    }

    // MARK: helpers
    private var weekdayShort: [String] {
        var cal = Calendar.current
        cal.locale = Locale.current
        let symbols = cal.veryShortStandaloneWeekdaySymbols
        return symbols.count == 7 ? symbols : ["S", "M", "T", "W", "T", "F", "S"]
    }

    // 6행 × 7열 = 42칸 고정으로 popup 높이 안정화.
    private var cells: [Int?] {
        var comps = DateComponents()
        comps.year = viewYear; comps.month = viewMonth; comps.day = 1
        guard let first = Calendar.current.date(from: comps) else { return [] }
        let offset = Calendar.current.component(.weekday, from: first) - 1
        let daysCount = Calendar.current.range(of: .day, in: .month, for: first)!.count
        let leading: [Int?] = Array(repeating: nil, count: offset)
        let dayCells: [Int?] = (1...daysCount).map { Optional($0) }
        let trailingCount = max(0, 42 - leading.count - dayCells.count)
        return leading + dayCells + Array(repeating: nil, count: trailingCount)
    }

    private func weekdayOf(day: Int) -> Int {
        guard let date = dateFor(day: day) else { return 0 }
        return Calendar.current.component(.weekday, from: date) - 1
    }

    private func dateFor(day: Int) -> Date? {
        var comps = DateComponents()
        comps.year = viewYear; comps.month = viewMonth; comps.day = day
        return Calendar.current.date(from: comps)
    }

    private func sameDay(_ a: Date?, _ b: Date?) -> Bool {
        guard let a = a, let b = b else { return false }
        return Calendar.current.isDate(a, inSameDayAs: b)
    }

    private func isStart(_ day: Int) -> Bool {
        sameDay(dateFor(day: day), pendingFrom)
    }

    private func isEnd(_ day: Int) -> Bool {
        sameDay(dateFor(day: day), pendingTo)
    }

    private func isInRange(_ day: Int) -> Bool {
        guard let from = pendingFrom, let to = pendingTo, let d = dateFor(day: day) else { return false }
        let cal = Calendar.current
        let f = cal.startOfDay(for: from)
        let t = cal.startOfDay(for: to)
        let x = cal.startOfDay(for: d)
        return x >= f && x <= t
    }

    private func selectDay(_ day: Int) {
        guard let date = dateFor(day: day) else { return }
        if pendingFrom == nil {
            pendingFrom = date
        } else if pendingTo == nil {
            if let from = pendingFrom,
               Calendar.current.startOfDay(for: date) < Calendar.current.startOfDay(for: from) {
                pendingTo = from
                pendingFrom = date
            } else {
                pendingTo = date
            }
        } else {
            pendingFrom = date
            pendingTo = nil
        }
    }

    private func prevMonth() {
        if viewMonth == 1 { viewYear -= 1; viewMonth = 12 } else { viewMonth -= 1 }
    }

    private func nextMonth() {
        guard !isAtCurrentMonth else { return }
        if viewMonth == 12 { viewYear += 1; viewMonth = 1 } else { viewMonth += 1 }
    }
}

private struct PixelDateRangeDayCell: View {
    let day: Int
    let isStart: Bool
    let isEnd: Bool
    let isInRange: Bool
    let weekday: Int
    let onTap: () -> Void

    private var isEndpoint: Bool { isStart || isEnd }

    private var bgColor: Color {
        if isEndpoint { return .peach }
        if isInRange { return Color.peach.opacity(0.3) }
        return .white
    }

    private var borderColor: Color {
        if isEndpoint { return .peachDk }
        if isInRange { return .ink.opacity(0.3) }
        return .ink
    }

    private var borderWidth: CGFloat { isEndpoint ? 2.5 : 1.5 }

    private var dayColor: Color {
        if isEndpoint { return .ink }
        switch weekday {
        case 0: return .redDk
        case 6: return Color(hex: "#3A7FC1")
        default: return .ink
        }
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Rectangle()
                    .fill(bgColor)
                    .overlay(Rectangle().stroke(borderColor, lineWidth: borderWidth))
                Text(String(format: "%02d", day))
                    .font(.pressStart9())
                    .foregroundColor(dayColor)
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
    }
}
