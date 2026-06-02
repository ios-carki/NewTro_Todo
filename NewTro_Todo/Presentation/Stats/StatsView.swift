import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: StatsViewModel

    @State private var calendarDate: Date = Date()

    var body: some View {
        ZStack {
            BackgroundSceneryView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 20) {
                        section(title: "투두") {
                            countsPanel
                        }
                        section(title: "최근 7일") {
                            weeklyChart
                        }
                        section(title: "퍼펙트 달력") {
                            perfectCalendar
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, TabSceneLayout.contentBottomMargin)
                }
                .scrollContentBackground(.hidden)
                .clipAboveGround()
            }
        }
        .overlay(alignment: .bottom) { FloatingTabBar() }
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

    // MARK: - Section wrapper
    @ViewBuilder
    private func section<Content: View>(
        title: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.galBold14())
                .foregroundColor(.ink)
                .padding(.leading, 2)
            content()
        }
    }

    // MARK: - Counts Panel
    private var countsPanel: some View {
        PixelPanel {
            VStack(spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    completedCell
                    incompleteCell
                }
                perfectCell
            }
        }
    }

    private var completedCell: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("완료")
                .font(.galBold11())
                .foregroundColor(.shade)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(viewModel.completedCount)")
                    .font(.pressStart20())
                    .foregroundColor(.grass)
                Text("/\(viewModel.totalCount)")
                    .font(.pressStart12())
                    .foregroundColor(.ink.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
    }

    private var incompleteCell: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("미완료")
                .font(.galBold11())
                .foregroundColor(.shade)
            Text("\(viewModel.incompleteCount)")
                .font(.pressStart20())
                .foregroundColor(.pixelRed)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.pixelRed, lineWidth: 1.5))
    }

    private var perfectCell: some View {
        HStack(spacing: 10) {
            Image(systemName: "star.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.sun)
            Text("퍼펙트")
                .font(.galBold11())
                .foregroundColor(.shade)
            Spacer()
            Text("\(viewModel.stats.totalPerfectDays)")
                .font(.pressStart14())
                .foregroundColor(.ink)
            Text("회")
                .font(.galBold11())
                .foregroundColor(.shade)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.sun, lineWidth: 1.5))
    }

    // MARK: - Weekly Chart

    private let weeklyChartBarHeight: CGFloat = 60

    private var weeklyChart: some View {
        PixelPanel {
            VStack(alignment: .leading, spacing: 10) {
                weeklyLegend

                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(0..<7, id: \.self) { i in
                        VStack(spacing: 3) {
                            countLabel(index: i)
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
                .frame(height: 110)
            }
        }
    }

    private var weeklyLegend: some View {
        HStack(spacing: 12) {
            legendSwatch(color: .grass, label: "완료")
            legendSwatch(color: .pixelRed, label: "미완료")
            Spacer()
        }
    }

    private func legendSwatch(color: Color, label: LocalizedStringKey) -> some View {
        HStack(spacing: 5) {
            Rectangle()
                .fill(color)
                .frame(width: 9, height: 9)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))
            Text(label)
                .font(.galBold10())
                .foregroundColor(.shade)
        }
    }

    private func countLabel(index: Int) -> some View {
        let total = index < viewModel.weeklyData.count ? viewModel.weeklyData[index].total : 0
        return Text("\(total)")
            .font(.pressStart8())
            .foregroundColor(total == 0 ? .shade.opacity(0.4) : (index == 6 ? .ink : .shade))
            .frame(height: 10)
    }

    private func barColumn(index: Int) -> some View {
        let counts = index < viewModel.weeklyData.count
            ? viewModel.weeklyData[index]
            : WeeklyDayCounts(completed: 0, incomplete: 0)

        return ZStack(alignment: .bottom) {
            Rectangle().fill(Color.panel).frame(height: weeklyChartBarHeight)

            if counts.isEmpty {
                // 작성된 Todo 없음 — 회색 베이스 라인.
                Rectangle()
                    .fill(Color.shade.opacity(0.3))
                    .frame(height: 2)
            } else {
                HStack(alignment: .bottom, spacing: 2) {
                    bar(count: counts.completed, color: .grass)
                    bar(count: counts.incomplete, color: .pixelRed)
                }
            }
        }
        .frame(height: weeklyChartBarHeight)
        .overlay(Rectangle().stroke(Color.ink.opacity(0.2), lineWidth: 1))
    }

    /// 한 색 막대 한 개. count == 0 면 매우 얕은 베이스 라인(stub) 만 그려 페어를 시각적으로 유지.
    private func bar(count: Int, color: Color) -> some View {
        let ratio = CGFloat(count) / CGFloat(viewModel.weeklyMax)
        let h: CGFloat = count > 0 ? max(ratio * weeklyChartBarHeight, 4) : 2
        return Rectangle()
            .fill(count > 0 ? color : Color.shade.opacity(0.25))
            .frame(maxWidth: .infinity)
            .frame(height: h)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: count > 0 ? 1 : 0))
    }

    // MARK: - Perfect Stamp Calendar
    private var perfectCalendar: some View {
        PerfectStampCalendar(
            month: $calendarDate,
            perfectDays: viewModel.perfectDays(for: calendarDate),
            monthLabel: viewModel.monthLabel(for: calendarDate),
            isCurrentMonth: viewModel.isCurrentMonth(calendarDate)
        )
    }
}
