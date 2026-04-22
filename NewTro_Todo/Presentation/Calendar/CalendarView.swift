import SwiftUI

private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

struct CalendarView: View {
    @StateObject var viewModel: CalendarViewModel
    var onBack: (() -> Void)?

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.sky.ignoresSafeArea()

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

            bottomNavWithGround
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .task { await viewModel.loadMonth() }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button { onBack?() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.ink)
                    .frame(width: 32, height: 32)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
            }

            Text("캘린더")
                .font(.galBold22())
                .foregroundColor(.ink)
                .padding(.leading, 8)

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
        HStack {
            Button { viewModel.prevMonth() } label: {
                Text("◀")
                    .font(.pressStart12())
                    .foregroundColor(.ink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }

            Spacer()

            Text(viewModel.monthTitle)
                .font(.pressStart14())
                .foregroundColor(.ink)

            Spacer()

            Button { viewModel.nextMonth() } label: {
                Text("▶")
                    .font(.pressStart12())
                    .foregroundColor(.ink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
        }
        .background(Color.cream)
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
                        onBack?()
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
            LegendDot(color: .cream,   label: "오늘", hasFrame: true)
        }
    }

    // MARK: - Bottom Nav
    private var bottomNavWithGround: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                navItem(label: "할일",  sfIcon: "list.bullet",    isActive: false) { onBack?() }
                navItem(label: "달력",  sfIcon: "calendar",       isActive: true)  { }
                navItem(label: "메모",  sfIcon: "pencil",         isActive: false) { }
                navItem(label: "통계",  sfIcon: "chart.bar.fill", isActive: false) { }
                navItem(label: "설정",  sfIcon: "gearshape.fill", isActive: false) { }
            }
            .frame(height: 60)
            .background(Color.panel)
            .overlay(alignment: .top) { Color.ink.frame(height: 2) }
            GroundStripView()
        }
    }

    private func navItem(label: String, sfIcon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: sfIcon)
                    .font(.system(size: 15))
                    .foregroundColor(isActive ? .ink : .shade)
                Text(label)
                    .font(.pressStart7())
                    .foregroundColor(isActive ? .ink : .shade)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isActive ? Color.sun.opacity(0.35) : Color.clear)
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
        isToday ? .cream : .white
    }

    private var dayColor: Color {
        switch weekday {
        case 0: return .redDk
        case 6: return .sky
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
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
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

    var body: some View {
        HStack(spacing: 4) {
            Rectangle()
                .fill(color)
                .frame(width: 10, height: 10)
                .overlay(hasFrame ? Rectangle().stroke(Color.ink, lineWidth: 1.5) : nil)
            Text(label)
                .font(.pressStart9())
                .foregroundColor(.shade)
        }
    }
}
