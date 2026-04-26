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
        ZStack {
            Color.sky.ignoresSafeArea()
            tabContent.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            tabBar
        }
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

            // Tab buttons
            HStack(spacing: 0) {
                tabItem(.todo,     label: "할일",   sfSymbol: "checkmark.square.fill")
                tabItem(.calendar, label: "달력",   sfSymbol: "calendar")
                tabItem(.memo,     label: "메모",   sfSymbol: "pencil")
                tabItem(.stats,    label: "통계",   sfSymbol: "chart.bar.fill")
                tabItem(.settings, label: "설정",   sfSymbol: "gearshape.fill")
            }
            .frame(height: 54)
        }
        .background(Color.cream.ignoresSafeArea(edges: .bottom))
    }

    // MARK: - Tab Item

    private func tabItem(_ tab: AppTab, label: String, sfSymbol: String) -> some View {
        let isActive = selectedTab == tab
        return Button { selectedTab = tab } label: {
            VStack(spacing: 4) {
                Spacer(minLength: 4)

                if isActive {
                    ZStack {
                        // Drop shadow
                        Rectangle()
                            .fill(Color.ink)
                            .frame(width: 38, height: 32)
                            .offset(x: 2, y: 2)
                        // Sun box
                        Rectangle()
                            .fill(Color.sun)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                            .frame(width: 38, height: 32)
                        // Icon
                        Image(systemName: sfSymbol)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.ink)
                    }
                } else {
                    Image(systemName: sfSymbol)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.shade)
                        .frame(width: 38, height: 32)
                }

                Text(label)
                    .font(.pressStart7())
                    .foregroundColor(isActive ? .ink : .shade)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Spacer(minLength: 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
        }
        .buttonStyle(.plain)
    }
}

let tabBarTotalHeight: CGFloat = 57  // 3pt border + 54pt buttons
