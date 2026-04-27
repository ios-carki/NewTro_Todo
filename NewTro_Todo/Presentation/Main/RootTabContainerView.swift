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
            // ZStack child로 사용 → ZStack 레이아웃은 safe area 경계 유지
            Color.sky.ignoresSafeArea()

            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 80)

            // 잔디+흙: safe area zone까지 흙색이 이어지도록 background 확장
            GroundStripView(height: 64)
                .frame(maxWidth: .infinity)
                .background(Color.dirt.ignoresSafeArea(edges: .bottom))

            // 탭바: alignment .bottom = safe area 상단 경계 → 패널이 safe area 침범 안 함
            floatingTabBar
                .padding(.horizontal, 14)
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

    // MARK: - Floating Tab Bar Panel
    // 레퍼런스 코드와 동일한 구조:
    // HStack 버튼들 + 패널 배경 + padding(.horizontal) → 공중에 뜬 느낌

    private var floatingTabBar: some View {
        HStack(spacing: 0) {
            tabItem(.todo,     label: "할일", sfSymbol: "checkmark.square.fill")
            tabItem(.calendar, label: "달력", sfSymbol: "calendar")
            tabItem(.memo,     label: "메모", sfSymbol: "pencil")
            tabItem(.stats,    label: "통계", sfSymbol: "chart.bar.fill")
            tabItem(.settings, label: "설정", sfSymbol: "gearshape.fill")
        }
        .frame(height: 62)
        // 픽셀 아트 패널: 크림 배경 + ink 테두리 + 우하단 드롭섀도
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 3))
        .background(Rectangle().fill(Color.ink).offset(x: 4, y: 4))
    }

    // MARK: - Tab Item

    private func tabItem(_ tab: AppTab, label: String, sfSymbol: String) -> some View {
        let isActive = selectedTab == tab
        return Button { selectedTab = tab } label: {
            VStack(spacing: 5) {
                Spacer(minLength: 0)

                if isActive {
                    // 선택: sun 박스 + 우하단 픽셀 드롭섀도
                    ZStack {
                        Rectangle()
                            .fill(Color.ink)
                            .frame(width: 38, height: 30)
                            .offset(x: 2, y: 2)
                        Rectangle()
                            .fill(Color.sun)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                            .frame(width: 38, height: 30)
                        Image(systemName: sfSymbol)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.ink)
                    }
                } else {
                    // 비선택: 아이콘만
                    Image(systemName: sfSymbol)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.shade)
                        .frame(width: 38, height: 30)
                }

                Text(label)
                    .font(.galBold14())
                    .foregroundColor(isActive ? .ink : .shade)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview { @MainActor in
    let di = DIContainer()
    return RootTabContainerView(
        mainVM: di.makeMainViewModel(),
        calendarVM: di.makeCalendarViewModel(),
        memoVM: di.makeMemoViewModel(),
        statsVM: di.makeStatsViewModel(),
        settingsVM: di.makeSettingsViewModel()
    )
}
