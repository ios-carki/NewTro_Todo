import SwiftUI

private let pickerWeekdays = ["일", "월", "화", "수", "목", "금", "토"]

struct PixelCalendarPicker: View {
    let onDateSelected: (Date) -> Void
    var minimumDate: Date? = nil
    var externalDate: Date? = nil

    @State private var viewYear: Int
    @State private var viewMonth: Int

    init(
        initialDate: Date = Date(),
        minimumDate: Date? = nil,
        externalDate: Date? = nil,
        onDateSelected: @escaping (Date) -> Void
    ) {
        let cal = Calendar.current
        let base = externalDate ?? initialDate
        _viewYear  = State(initialValue: cal.component(.year,  from: base))
        _viewMonth = State(initialValue: cal.component(.month, from: base))
        self.minimumDate   = minimumDate
        self.externalDate  = externalDate
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

            Text(monthTitle)
                .font(.pressStart14())
                .foregroundColor(.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color.panel)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))

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
                        onTap:       { selectDay(d) }
                    )
                } else {
                    Color.clear.frame(height: 46)
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
}

// MARK: - Day Cell

private struct PickerDayCell: View {
    let day: Int
    let isToday: Bool
    let isHighlighted: Bool
    let isDisabled: Bool
    let weekday: Int
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
            Text(String(format: "%02d", day))
                .font(.pressStart10())
                .foregroundColor(dayColor)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(isDisabled ? Color.shade.opacity(0.04) : bgColor)
                .overlay(Rectangle().stroke(borderColor, lineWidth: borderWidth))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}
