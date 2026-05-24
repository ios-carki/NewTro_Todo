import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: StatsViewModel
    let makeIncompleteListVM: @MainActor () -> IncompleteListViewModel

    @State private var calendarDate: Date = Date()
    private let tabBarHeight: CGFloat = 113

    var body: some View {
        NavigationStack {
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
            .navigationBarHidden(true)
            .navigationDestination(for: StatsRoute.self) { route in
                switch route {
                case .incompleteList:
                    IncompleteListView(viewModel: makeIncompleteListVM())
                case .incompleteDetail(let todo):
                    IncompleteTodoDetailView(todo: todo)
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
            HStack(alignment: .top, spacing: 12) {
                completedCell
                NavigationLink(value: StatsRoute.incompleteList) {
                    incompleteCell
                }
                .buttonStyle(.plain)
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
            HStack(spacing: 4) {
                Text("미완료")
                    .font(.galBold11())
                    .foregroundColor(.shade)
                Spacer(minLength: 0)
                Text("▶")
                    .font(.pressStart8())
                    .foregroundColor(.pixelRed)
            }
            Text("\(viewModel.incompleteCount)")
                .font(.pressStart20())
                .foregroundColor(.pixelRed)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.pixelRed, lineWidth: 1.5))
    }

    // MARK: - Weekly Chart
    private var weeklyChart: some View {
        PixelPanel {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("최근 7일")
                        .font(.galBold11())
                        .foregroundColor(.shade)
                    Spacer()
                    Text("작성된 Todo")
                        .font(.pressStart8())
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

// MARK: - Routes
enum StatsRoute: Hashable {
    case incompleteList
    case incompleteDetail(TodoEntity)
}
