import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: StatsViewModel

    @State private var calendarDate: Date = Date()
    private let tabBarHeight: CGFloat = 113

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
                        .padding(.bottom, tabBarHeight + 16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .scrollContentBackground(.hidden)
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
    private var weeklyChart: some View {
        PixelPanel {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Spacer()
                    Text("작성된 Todo")
                        .font(.galBold10())
                        .foregroundColor(.shade.opacity(0.7))
                }

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

    private func countLabel(index: Int) -> some View {
        let count = index < viewModel.weeklyData.count ? viewModel.weeklyData[index] : 0
        return Text("\(count)")
            .font(.pressStart8())
            .foregroundColor(count == 0 ? .shade.opacity(0.4) : (index == 6 ? .ink : .shade))
            .frame(height: 10)
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
        PerfectStampCalendar(
            month: $calendarDate,
            perfectDays: viewModel.perfectDays(for: calendarDate),
            monthLabel: viewModel.monthLabel(for: calendarDate),
            isCurrentMonth: viewModel.isCurrentMonth(calendarDate)
        )
    }
}
