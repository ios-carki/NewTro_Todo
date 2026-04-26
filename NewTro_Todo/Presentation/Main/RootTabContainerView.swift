import SwiftUI

enum AppTab: Equatable {
    case todo, calendar, memo, stats, settings
}

struct RootTabContainerView: View {
    @State private var selectedTab: AppTab = .todo
    @ObservedObject var mainVM: MainViewModel
    @ObservedObject var calendarVM: CalendarViewModel
    @ObservedObject var memoVM: MemoViewModel
    @ObservedObject var statsVM: StatsViewModel
    @ObservedObject var settingsVM: SettingsViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.sky.ignoresSafeArea()

            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            tabBar
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .todo:
            MainView(
                viewModel: mainVM,
                onCalendarTapped: { selectedTab = .calendar },
                onMemoTapped: { selectedTab = .memo }
            )
        case .calendar:
            CalendarView(
                viewModel: calendarVM,
                onDateSelected: { date in
                    mainVM.selectedDate = date
                    mainVM.loadTodos()
                    selectedTab = .todo
                }
            )
        case .memo:
            MemoView(viewModel: memoVM)
        case .stats:
            StatsView(viewModel: statsVM)
        case .settings:
            SettingsView(viewModel: settingsVM, statsVM: statsVM)
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        VStack(spacing: 0) {
            // Top border
            Color.ink.frame(height: 3)

            // Tab buttons on cream background
            HStack(spacing: 0) {
                tabItem(.todo,     label: "할일", icon: PixelArtAssets.tabIconTodo)
                tabItem(.calendar, label: "달력", icon: PixelArtAssets.tabIconCalendar)
                tabItem(.memo,     label: "메모", icon: PixelArtAssets.tabIconMemo)
                tabItem(.stats,    label: "통계", icon: PixelArtAssets.tabIconStats)
                tabItem(.settings, label: "설정", icon: PixelArtAssets.tabIconSettings)
            }
            .frame(height: 66)
            .background(Color.cream)

            // Bottom safe area fill
            Color.cream
                .frame(height: 40)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Tab Item

    private func tabItem(_ tab: AppTab, label: String, icon: [String]) -> some View {
        let isActive = selectedTab == tab
        return Button { selectedTab = tab } label: {
            VStack(spacing: 4) {
                Spacer(minLength: 0)

                // Icon in selected box or plain
                ZStack {
                    if isActive {
                        Color.sun
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                            .frame(width: 34, height: 28)
                            .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
                    }
                    PixelTabIcon(grid: icon, isActive: isActive)
                }

                // Label
                Text(label)
                    .font(.pressStart7())
                    .foregroundColor(.ink)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pixel Tab Icon

private struct PixelTabIcon: View {
    let grid: [String]
    let isActive: Bool

    private let pixelSize: CGFloat = 3

    var body: some View {
        let cols = CGFloat(grid.first?.count ?? 7)
        let rows = CGFloat(grid.count)

        return Canvas { ctx, _ in
            for (r, row) in grid.enumerated() {
                for (c, ch) in row.enumerated() {
                    guard ch == "1" else { continue }
                    let rect = CGRect(
                        x: CGFloat(c) * pixelSize,
                        y: CGFloat(r) * pixelSize,
                        width: pixelSize,
                        height: pixelSize
                    )
                    ctx.fill(Path(rect), with: .color(Color.ink))
                }
            }
        }
        .frame(width: cols * pixelSize, height: rows * pixelSize)
    }
}

// Keep the constant for padding references elsewhere
let tabBarTotalHeight: CGFloat = 115
