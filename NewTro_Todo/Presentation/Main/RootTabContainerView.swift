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
        // SplashView와 동일한 패턴: GeometryReader + ignoresSafeArea로 물리적 화면 전체 기준
        GeometryReader { geo in
            let safeBottom = geo.safeAreaInsets.bottom
            ZStack(alignment: .bottom) {
                Color.sky

                // 콘텐츠 — 탭바 + safe area 만큼 아래를 비워줌
                tabContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, safeBottom + 62 + 16)

                // 잔디+흙: 물리적 최하단에 붙음 (canvas가 safe area zone까지 커버)
                GroundStripView(height: 64)
                    .frame(maxWidth: .infinity)

                // 탭바: safe area 바로 위에 위치 (패널이 safe area 침범 안 함)
                floatingTabBar
                    .padding(.horizontal, 14)
                    .padding(.bottom, safeBottom)
            }
        }
        .ignoresSafeArea()
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
