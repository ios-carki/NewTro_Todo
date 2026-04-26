import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: StatsViewModel
    @State private var calendarDate: Date = Date()
    private let tabBarHeight: CGFloat = 113

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                scorePanel
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                statsGrid
                    .padding(.horizontal, 16)

                weeklyChart
                    .padding(.horizontal, 16)

                perfectCalendar
                    .padding(.horizontal, 16)
                    .padding(.bottom, tabBarHeight + 16)
            }
        }
        .onAppear { viewModel.loadStats() }
    }

    // MARK: - Score Panel
    private var scorePanel: some View {
        PixelPanel {
            VStack(spacing: 8) {
                HStack {
                    Text("SCORE")
                        .font(.pressStart9())
                        .foregroundColor(.shade)
                    Spacer()
                    Text("LV.\(viewModel.stats.level)")
                        .font(.pressStart12())
                        .foregroundColor(.sun)
                }

                Text("\(viewModel.stats.totalScore)")
                    .font(.pressStart34())
                    .foregroundColor(.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .minimumScaleFactor(0.5)

                Text(viewModel.levelTitle)
                    .font(.pressStart9())
                    .foregroundColor(.pinkDk)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color.panel)
                        Rectangle()
                            .fill(Color.sun)
                            .frame(width: geo.size.width * min(CGFloat(viewModel.stats.progressToNextLevel), 1))
                            .animation(.easeInOut(duration: 0.4), value: viewModel.stats.progressToNextLevel)
                    }
                }
                .frame(height: 14)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))

                HStack {
                    Spacer()
                    Text("NEXT LV: \(viewModel.stats.nextLevelScore)")
                        .font(.pressStart7())
                        .foregroundColor(.shade)
                }
            }
        }
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            statCell(label: "연속기록", value: "\(viewModel.stats.currentStreak)일", icon: "flame.fill", color: .peach)
            statCell(label: "완료",    value: "\(viewModel.stats.totalCompleted)개", icon: "checkmark.circle.fill", color: .done)
            statCell(label: "최장연속", value: "\(viewModel.stats.longestStreak)일",  icon: "bolt.fill", color: .sun)
            statCell(label: "퍼펙트",  value: "\(viewModel.stats.totalPerfectDays)회", icon: "star.fill", color: .sun)
        }
    }

    private func statCell(label: String, value: String, icon: String, color: Color) -> some View {
        PixelPanel(bg: .panel, padding: 10) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: icon).font(.system(size: 10)).foregroundColor(color)
                    Text(label).font(.pressStart7()).foregroundColor(.shade)
                }
                Text(value).font(.pressStart14()).foregroundColor(.ink).minimumScaleFactor(0.6)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Weekly Chart
    private var weeklyChart: some View {
        PixelPanel {
            VStack(alignment: .leading, spacing: 10) {
                Text("WEEKLY")
                    .font(.pressStart9())
                    .foregroundColor(.shade)

                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(0..<7, id: \.self) { i in
                        VStack(spacing: 3) {
                            Spacer()
                            barColumn(index: i)
                            Text(viewModel.weeklyLabels.indices.contains(i) ? viewModel.weeklyLabels[i] : "")
                                .font(.pressStart7())
                                .foregroundColor(i == 6 ? .ink : .shade.opacity(0.7))
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 90)
            }
        }
    }

    private func barColumn(index: Int) -> some View {
        let count = index < viewModel.weeklyData.count ? viewModel.weeklyData[index] : 0
        let ratio = CGFloat(count) / CGFloat(viewModel.weeklyMax)
        let barH = max(ratio * 60, count > 0 ? 4 : 2)
        let barColor: Color = index == 6 ? .grass : .done

        return ZStack(alignment: .bottom) {
            Rectangle().fill(Color.panel).frame(height: 60)
            Rectangle()
                .fill(barColor)
                .frame(height: barH)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))
        }
        .frame(height: 60)
        .overlay(Rectangle().stroke(Color.ink.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Perfect Stamp Calendar
    private var perfectCalendar: some View {
        PixelPanel {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("PERFECT DAYS")
                        .font(.pressStart9())
                        .foregroundColor(.shade)
                    Spacer()
                    HStack(spacing: 8) {
                        Button {
                            calendarDate = Calendar.current.date(
                                byAdding: .month, value: -1, to: calendarDate
                            ) ?? calendarDate
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.shade)
                        }
                        Text(viewModel.monthLabel(for: calendarDate))
                            .font(.pressStart7())
                            .foregroundColor(.shade)
                        Button {
                            let next = Calendar.current.date(
                                byAdding: .month, value: 1, to: calendarDate
                            ) ?? calendarDate
                            if !Calendar.current.isDate(next, equalTo: Date(), toGranularity: .month),
                               next > Date() { return }
                            calendarDate = next
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(viewModel.isCurrentMonth(calendarDate) ? .shade.opacity(0.2) : .shade)
                        }
                        .disabled(viewModel.isCurrentMonth(calendarDate))
                    }
                }

                let cells      = calendarCells(for: calendarDate)
                let perfectSet = viewModel.perfectDays(for: calendarDate)
                let todayDay: Int? = viewModel.isCurrentMonth(calendarDate)
                    ? Calendar.current.component(.day, from: Date())
                    : nil

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                    ForEach(["S","M","T","W","T","F","S"], id: \.self) { d in
                        Text(d).font(.pressStart7()).foregroundColor(.shade).frame(height: 16)
                    }
                    ForEach(0..<cells.count, id: \.self) { i in
                        if let day = cells[i] {
                            calendarCell(day: day, isPerfect: perfectSet.contains(day), isToday: day == todayDay)
                        } else {
                            Color.clear.frame(height: 26)
                        }
                    }
                }

                HStack {
                    Text(viewModel.monthLabel(for: calendarDate))
                        .font(.pressStart7())
                        .foregroundColor(.shade)
                    Text("→")
                        .font(.pressStart7())
                        .foregroundColor(.shade)
                    Text("퍼펙트 \(perfectSet.count)회")
                        .font(.pressStart7())
                        .foregroundColor(perfectSet.isEmpty ? .shade.opacity(0.4) : .sun)
                }
                .padding(.top, 4)
            }
        }
    }

    private func calendarCell(day: Int, isPerfect: Bool, isToday: Bool) -> some View {
        ZStack {
            if isPerfect {
                Color.sun.opacity(0.4)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))
                Text("\(day)")
                    .font(.pressStart7())
                    .foregroundColor(.ink)
                Image(systemName: "star.fill")
                    .font(.system(size: 6))
                    .foregroundColor(.sun)
                    .offset(x: 6, y: -6)
            } else {
                (isToday ? Color.pixelPink.opacity(0.2) : Color.clear)
                    .overlay(Rectangle().stroke(isToday ? Color.ink : Color.clear, lineWidth: 1))
                Text("\(day)")
                    .font(.pressStart7())
                    .foregroundColor(isToday ? .ink : .shade.opacity(0.6))
            }
        }
        .frame(height: 26)
    }

    private func calendarCells(for date: Date) -> [Int?] {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.year  = cal.component(.year,  from: date)
        comps.month = cal.component(.month, from: date)
        comps.day   = 1
        guard let first = cal.date(from: comps),
              let count = cal.range(of: .day, in: .month, for: first)?.count else { return [] }
        let weekday = cal.component(.weekday, from: first) - 1
        return Array(repeating: nil, count: weekday) + (1...count).map { Optional($0) }
    }
}
