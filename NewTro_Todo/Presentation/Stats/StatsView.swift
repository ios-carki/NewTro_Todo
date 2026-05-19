import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: StatsViewModel
    @State private var calendarDate: Date = Date()
    private let tabBarHeight: CGFloat = 113

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 8)

            ScrollView {
                VStack(spacing: 16) {
                    countsPanel
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    weeklyChart
                        .padding(.horizontal, 16)

                    perfectCalendar
                        .padding(.horizontal, 16)
                        .padding(.bottom, tabBarHeight + 16)
                }
            }
        }
        .onAppear { viewModel.loadStats() }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Text("통계")
                .font(.galBold22())
                .foregroundColor(.ink)
            Spacer()
        }
        .padding(.vertical, 6)
    }

    // MARK: - Counts Panel
    private var countsPanel: some View {
        PixelPanel {
            HStack(spacing: 12) {
                countCell(title: "완료", value: viewModel.completedCount, accent: .grass)
                countCell(title: "미완료", value: viewModel.incompleteCount, accent: .peachDk)
            }
        }
    }

    private func countCell(title: String, value: Int, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.galBold11())
                .foregroundColor(.shade)
            Text("\(value)")
                .font(.pressStart14())
                .foregroundColor(accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
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
                                .font(.pressStart9())
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
                            .font(.pressStart9())
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
                        Text(d).font(.pressStart9()).foregroundColor(.shade).frame(height: 16)
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
                        .font(.pressStart9())
                        .foregroundColor(.shade)
                    Text("→")
                        .font(.pressStart9())
                        .foregroundColor(.shade)
                    Text("퍼펙트 %d회".localized(with: perfectSet.count))
                        .font(.pressStart9())
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
                    .font(.pressStart9())
                    .foregroundColor(.ink)
                Image(systemName: "star.fill")
                    .font(.system(size: 6))
                    .foregroundColor(.sun)
                    .offset(x: 6, y: -6)
            } else {
                (isToday ? Color.pixelPink.opacity(0.2) : Color.clear)
                    .overlay(Rectangle().stroke(isToday ? Color.ink : Color.clear, lineWidth: 1))
                Text("\(day)")
                    .font(.pressStart9())
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
