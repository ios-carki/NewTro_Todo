import SwiftUI

private var pickerWeekdays: [String] {
    var cal = Calendar.current
    cal.locale = Locale.current
    let symbols = cal.veryShortStandaloneWeekdaySymbols
    return symbols.count == 7 ? symbols : ["S", "M", "T", "W", "T", "F", "S"]
}

struct PixelCalendarPicker: View {
    let onDateSelected: (Date) -> Void
    var minimumDate: Date? = nil
    var externalDate: Date? = nil
    var monthOverviewProvider: ((Int, Int) async -> [Int: DayContent])? = nil
    var onHeaderTap: (() -> Void)? = nil

    @State private var viewYear: Int
    @State private var viewMonth: Int
    @State private var dayContent: [Int: DayContent] = [:]

    init(
        initialDate: Date = Date(),
        minimumDate: Date? = nil,
        externalDate: Date? = nil,
        monthOverviewProvider: ((Int, Int) async -> [Int: DayContent])? = nil,
        onHeaderTap: (() -> Void)? = nil,
        onDateSelected: @escaping (Date) -> Void
    ) {
        let cal = Calendar.current
        let base = externalDate ?? initialDate
        _viewYear  = State(initialValue: cal.component(.year,  from: base))
        _viewMonth = State(initialValue: cal.component(.month, from: base))
        self.minimumDate   = minimumDate
        self.externalDate  = externalDate
        self.monthOverviewProvider = monthOverviewProvider
        self.onHeaderTap = onHeaderTap
        self.onDateSelected = onDateSelected
    }

    var body: some View {
        VStack(spacing: 0) {
            monthNavPanel
                .padding(.horizontal, 14)

            calendarGrid
                .padding(.horizontal, 14)
                .padding(.top, 10)
        }
        .onAppear { reloadOverview() }
        .onChange(of: viewYear) { _ in reloadOverview() }
        .onChange(of: viewMonth) { _ in reloadOverview() }
        .onChange(of: externalDate) { newDate in
            guard let d = newDate else { return }
            let cal = Calendar.current
            viewYear  = cal.component(.year,  from: d)
            viewMonth = cal.component(.month, from: d)
        }
    }

    // MARK: - Month Navigation

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

            HStack(spacing: 6) {
                Text(monthTitle)
                    .font(.pressStart14())
                    .foregroundColor(.ink)
                if onHeaderTap != nil {
                    Text("▼")
                        .font(.pressStart8())
                        .foregroundColor(.ink)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(Color.panel)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            .contentShape(Rectangle())
            .onTapGesture { onHeaderTap?() }

            Button { nextMonth() } label: {
                Text("▶")
                    .font(.pressStart14())
                    .foregroundColor(.ink)
                    .frame(width: 50, height: 46)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            }
        }
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        PixelPanel(bg: .white, padding: 6) {
            VStack(spacing: 4) {
                weekdayHeader
                dayGrid
            }
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { i in
                Text(pickerWeekdays[i])
                    .font(.galBold14())
                    .foregroundColor(i == 0 ? .pixelRed : i == 6 ? .sky : .shade)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
        }
    }

    private var dayGrid: some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)
        return LazyVGrid(columns: cols, spacing: 3) {
            ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                if let d = day {
                    PickerDayCell(
                        day:         d,
                        isToday:     isToday(day: d),
                        isHighlighted: isHighlighted(day: d),
                        isDisabled:  isDisabled(day: d),
                        weekday:     weekdayOf(day: d),
                        marker:      dayContent[d] ?? DayContent(),
                        onTap:       { selectDay(d) }
                    )
                } else {
                    Color.clear.frame(height: 50)
                }
            }
        }
    }

    // MARK: - Helpers

    private var monthTitle: String { String(format: "%d.%02d", viewYear, viewMonth) }

    private var cells: [Int?] {
        var comps = DateComponents()
        comps.year = viewYear; comps.month = viewMonth; comps.day = 1
        guard let first = Calendar.current.date(from: comps) else { return [] }
        let offset    = Calendar.current.component(.weekday, from: first) - 1
        let daysCount = Calendar.current.range(of: .day, in: .month, for: first)!.count
        return Array(repeating: nil, count: offset) + (1...daysCount).map { Optional($0) }
    }

    private func isToday(day: Int) -> Bool {
        let cal = Calendar.current; let now = Date()
        return cal.component(.year,  from: now) == viewYear &&
               cal.component(.month, from: now) == viewMonth &&
               cal.component(.day,   from: now) == day
    }

    private func isHighlighted(day: Int) -> Bool {
        guard let ext = externalDate else { return false }
        let cal = Calendar.current
        return cal.component(.year,  from: ext) == viewYear &&
               cal.component(.month, from: ext) == viewMonth &&
               cal.component(.day,   from: ext) == day
    }

    private func isDisabled(day: Int) -> Bool {
        guard let min = minimumDate else { return false }
        var comps = DateComponents()
        comps.year = viewYear; comps.month = viewMonth; comps.day = day
        guard let date = Calendar.current.date(from: comps) else { return true }
        return date < Calendar.current.startOfDay(for: min)
    }

    private func weekdayOf(day: Int) -> Int {
        var comps = DateComponents()
        comps.year = viewYear; comps.month = viewMonth; comps.day = day
        guard let date = Calendar.current.date(from: comps) else { return 0 }
        return Calendar.current.component(.weekday, from: date) - 1
    }

    private func selectDay(_ day: Int) {
        guard !isDisabled(day: day) else { return }
        var comps = DateComponents()
        comps.year = viewYear; comps.month = viewMonth; comps.day = day
        guard let date = Calendar.current.date(from: comps) else { return }
        onDateSelected(date)
    }

    private func prevMonth() {
        if viewMonth == 1 { viewYear -= 1; viewMonth = 12 } else { viewMonth -= 1 }
    }

    private func nextMonth() {
        if viewMonth == 12 { viewYear += 1; viewMonth = 1 } else { viewMonth += 1 }
    }

    private func reloadOverview() {
        guard let provider = monthOverviewProvider else { return }
        let y = viewYear, m = viewMonth
        Task {
            let map = await provider(y, m)
            await MainActor.run {
                guard y == self.viewYear, m == self.viewMonth else { return }
                self.dayContent = map
            }
        }
    }
}

// MARK: - Day Cell

private struct PickerDayCell: View {
    let day: Int
    let isToday: Bool
    let isHighlighted: Bool
    let isDisabled: Bool
    let weekday: Int
    let marker: DayContent
    let onTap: () -> Void

    private var bgColor: Color {
        if isHighlighted { return .peach }
        if isToday { return Color(hex: "#FFD6E0").opacity(0.5) }
        return .white
    }

    private var borderColor: Color {
        if isHighlighted { return .peachDk }
        if isToday { return .pixelPink }
        return isDisabled ? .ink.opacity(0.15) : .ink
    }

    private var borderWidth: CGFloat { (isHighlighted || isToday) ? 2.5 : 2 }

    private var dayColor: Color {
        if isDisabled { return .shade.opacity(0.25) }
        if isHighlighted { return .ink }
        switch weekday {
        case 0: return .redDk
        case 6: return Color(hex: "#3A7FC1")
        default: return .ink
        }
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 셀 배경 + 보더
                Rectangle()
                    .fill(isDisabled ? Color.shade.opacity(0.04) : bgColor)
                    .overlay(Rectangle().stroke(borderColor, lineWidth: borderWidth))

                // 날짜 — 셀 정중앙. fold/+N 과 시각적으로 분리되도록 배치.
                Text(String(format: "%02d", day))
                    .font(.pressStart10())
                    .foregroundColor(dayColor)

                // 메모 fold (우상단 코너) — 메모 있을 때만 (개수 표시 없이 플래그만)
                if marker.memoCount > 0 {
                    MemoFoldCorner(isDisabled: isDisabled)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }

                // Todo 사각형 row (하단)
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    todoSquaresRow
                        .padding(.bottom, 5)
                }
            }
            .frame(height: 50)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    // MARK: - Todo 사각형 row
    // 0개: 비움 / 1·2·3개: 그만큼 ▣ / 4개 이상: ▣▣▣ +N (남은 개수)
    @ViewBuilder
    private var todoSquaresRow: some View {
        if marker.todoCount > 0 {
            HStack(spacing: 2) {
                let shown = min(marker.todoCount, 3)
                ForEach(0..<shown, id: \.self) { _ in todoSquare }
                if marker.todoCount > 3 {
                    Text("+\(marker.todoCount - 3)")
                        .font(.pressStart8())
                        .foregroundColor(.ink)
                        .monospacedDigit()
                }
            }
            .opacity(isDisabled ? 0.35 : 1)
            .frame(height: 6)
        } else {
            Color.clear.frame(height: 6)
        }
    }

    private var todoSquare: some View {
        Rectangle()
            .fill(Color.pixelPink)
            .frame(width: 5, height: 5)
            .overlay(Rectangle().stroke(Color.ink.opacity(0.55), lineWidth: 1))
    }
}

// MARK: - Memo Fold Corner
// 우상단 코너가 접힌 종이 모양. "메모 있음" 시각 플래그 전용 (개수 미표시).
private struct MemoFoldCorner: View {
    let isDisabled: Bool

    private let foldSize: CGFloat = 12

    var body: some View {
        ZStack {
            FoldTriangleShape()
                .fill(Color.peachDk)
            FoldEdgeShape()
                .stroke(Color.ink, lineWidth: 1)
        }
        .frame(width: foldSize, height: foldSize)
        .opacity(isDisabled ? 0.35 : 1)
    }
}

// 우상단 → 우하단 → 좌상단을 잇는 직각삼각형 (페이지가 접혀 내려온 면)
private struct FoldTriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

// 접힘선(좌상단 ↔ 우하단)만 한 줄
private struct FoldEdgeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return p
    }
}
