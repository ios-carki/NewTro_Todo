import SwiftUI

private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

struct CalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    var onDateSelected: ((Date) -> Void)?

    init(viewModel: CalendarViewModel, onDateSelected: ((Date) -> Void)? = nil) {
        self.viewModel = viewModel
        self.onDateSelected = onDateSelected
        viewModel.onDateSelected = onDateSelected
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 14)
                .padding(.top, 8)

            monthNavPanel
                .padding(.horizontal, 14)
                .padding(.top, 10)

            calendarGrid
                .padding(.horizontal, 14)
                .padding(.top, 10)

            legend
                .padding(.top, 10)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 113)
        .task { await viewModel.loadMonth() }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Text("캘린더")
                .font(.galBold22())
                .foregroundColor(.ink)

            Spacer()

            HStack(spacing: 4) {
                PixelArtView(grid: PixelArtAssets.starGrid, palette: PixelArtAssets.starPalette, scale: 2)
                Text("×\(viewModel.totalDoneThisMonth)")
                    .font(.pressStart10())
                    .foregroundColor(.ink)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Month Navigation Panel
    private var monthNavPanel: some View {
        HStack(spacing: 0) {
            Button { viewModel.prevMonth() } label: {
                Text("◀")
                    .font(.pressStart14())
                    .foregroundColor(.ink)
                    .frame(width: 50, height: 46)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            }

            Text(viewModel.monthTitle)
                .font(.pressStart14())
                .foregroundColor(.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color.panel)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))

            Button { viewModel.nextMonth() } label: {
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
                Text(weekdays[i])
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
            ForEach(Array(viewModel.cells.enumerated()), id: \.offset) { _, day in
                if let d = day {
                    DayCellView(
                        day: d,
                        info: viewModel.todosByDay[String(format: "%02d", d)],
                        isToday: viewModel.isToday(day: d),
                        weekday: viewModel.weekday(day: d)
                    ) {
                        viewModel.selectDay(d)
                    }
                } else {
                    Color.clear.frame(height: 46)
                }
            }
        }
    }

    // MARK: - Legend
    private var legend: some View {
        HStack(spacing: 16) {
            LegendDot(color: .peachDk, label: "할 일")
            LegendDot(color: .grassDk, label: "완료")
            LegendDot(color: Color(hex: "#FFD6E0").opacity(0.5), label: "오늘", hasFrame: true, frameColor: .pixelPink)
        }
    }
}

// MARK: - DayCellView
private struct DayCellView: View {
    let day: Int
    let info: DayInfo?
    let isToday: Bool
    let weekday: Int
    let onTap: () -> Void

    private var bg: Color {
        isToday ? Color(hex: "#FFD6E0").opacity(0.5) : .white
    }

    private var dayColor: Color {
        switch weekday {
        case 0: return .redDk
        case 6: return Color(hex: "#3A7FC1")
        default: return .ink
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text(String(format: "%02d", day))
                    .font(.pressStart10())
                    .foregroundColor(dayColor)

                if let info, info.total > 0 {
                    todoDots(info: info)
                } else {
                    Spacer().frame(height: 7)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .padding(.vertical, 4)
            .background(bg)
            .overlay(Rectangle().stroke(isToday ? Color.pixelPink : Color.ink, lineWidth: isToday ? 2.5 : 2))
        }
        .buttonStyle(.plain)
    }

    private func todoDots(info: DayInfo) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<min(info.total, 3), id: \.self) { i in
                Rectangle()
                    .fill(i < info.done ? Color.grassDk : Color.peachDk)
                    .frame(width: 4, height: 4)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 0.5))
            }
        }
    }
}

// MARK: - LegendDot
private struct LegendDot: View {
    let color: Color
    let label: String
    var hasFrame: Bool = false
    var frameColor: Color = .ink

    var body: some View {
        HStack(spacing: 4) {
            Rectangle()
                .fill(color)
                .frame(width: 10, height: 10)
                .overlay(hasFrame ? Rectangle().stroke(frameColor, lineWidth: 1.5) : nil)
            Text(label)
                .font(.pressStart9())
                .foregroundColor(.shade)
        }
    }
}
