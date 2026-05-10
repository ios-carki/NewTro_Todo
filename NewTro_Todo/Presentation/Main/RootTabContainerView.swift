import SwiftUI

enum AppTab: Equatable {
    case todo, memo, stats, settings
}

struct RootTabContainerView: View {
    @State private var selectedTab: AppTab = .todo
    // UIHostingController가 UINavigationController에 직접 올라가므로
    // ZStack은 safe area 없이 물리적 전체 화면을 채움 → safe area 값을 직접 읽어야 함
    @State private var safeAreaBottom: CGFloat = 34

    // 같은 탭 재선택 시 NavigationView를 재생성해 root까지 pop
    @State private var todoTabId     = UUID()
    @State private var memoTabId     = UUID()
    @State private var statsTabId    = UUID()
    @State private var settingsTabId = UUID()

    @AppStorage("hasSeenTodoOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var showCoachmark: Bool = false

    @ObservedObject var mainVM: MainViewModel
    @ObservedObject var memoVM: MemoViewModel
    @ObservedObject var statsVM: StatsViewModel
    @ObservedObject var settingsVM: SettingsViewModel
    
    var body: some View {
        ZStack {
            // GeometryReader로 실제 safe area 값 취득 + 하늘 배경 (전체 화면 덮음)
            GeometryReader { geo in
                Color.sky
                    .onAppear { safeAreaBottom = geo.safeAreaInsets.bottom }
            }
            .ignoresSafeArea()
            
            // 콘텐츠: 탭바 + safe area 영역 아래를 비워줌
            tabContent
            //                .frame(maxWidth: .infinity, maxHeight: .infinity)
            ////                .padding(.bottom, safeAreaBottom + 62 + 16)
            //
            //            // 잔디+흙: ZStack이 물리적 전체화면이므로 자연스럽게 최하단에 위치
            //            GroundStripView(height: 64)
            //                .ignoresSafeArea(edges: .bottom)
            ////                .frame(maxWidth: .infinity)
            //
            //            // 탭바: safeAreaBottom만큼 올려 home indicator zone 침범 방지
            //            floatingTabBar
            //                .padding(.horizontal, 14)
            ////                .padding(.bottom, safeAreaBottom)
            ///
            
            VStack {
                Spacer()
                GroundStripView(height: 64)
            }
            .ignoresSafeArea(edges: .bottom)
            
            VStack {
                Spacer()
                floatingTabBar
                    .clipped()
                    .padding(.horizontal, 14)
                    .padding(.bottom, 16)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        //        .overlay(alignment: .bottom) {
        //            floatingTabBar
        //                .padding(.horizontal, 14)
        //                .ignoresSafeArea(edges: .bottom)
        //        }
        .overlayPreferenceValue(CoachmarkAnchorKey.self) { anchors in
            GeometryReader { geom in
                if showCoachmark {
                    CoachmarkOverlay(
                        isActive: $showCoachmark,
                        steps: CoachmarkSteps.main,
                        anchors: anchors,
                        geom: geom
                    )
                }
            }
            .ignoresSafeArea()
        }
        .navigationBarHidden(true)
        .onAppear {
            if !hasSeenOnboarding {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showCoachmark = true
                }
            }
        }
        .onChange(of: showCoachmark) { newValue in
            if !newValue { hasSeenOnboarding = true }
        }
        .onReceive(NotificationCenter.default.publisher(for: .replayTodoCoachmark)) { _ in
            selectedTab = .todo
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showCoachmark = true
            }
        }
    }

    // MARK: - Tab Content
    
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .todo:
            MainView(viewModel: mainVM).id(todoTabId)
        case .memo:
            MemoView(viewModel: memoVM).id(memoTabId)
        case .stats:
            StatsView(viewModel: statsVM).id(statsTabId)
        case .settings:
            SettingsView(viewModel: settingsVM, statsVM: statsVM).id(settingsTabId)
        }
    }
    
    // MARK: - Floating Tab Bar Panel
    
    private var floatingTabBar: some View {
        HStack(spacing: 0) {
            tabItem(.todo,     label: "할일", sfSymbol: "checkmark.square.fill")
            tabItem(.memo,     label: "메모", sfSymbol: "pencil")
            tabItem(.stats,    label: "통계", sfSymbol: "chart.bar.fill")
            tabItem(.settings, label: "설정", sfSymbol: "gearshape.fill")
        }
        .frame(height: 62)
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 3))
        .background(Rectangle().fill(Color.ink).offset(x: 4, y: 4))
    }

    // MARK: - Tab Reset

    private func resetTab(_ tab: AppTab) {
        switch tab {
        case .todo:     todoTabId = UUID()
        case .memo:     memoTabId = UUID()
        case .stats:    statsTabId = UUID()
        case .settings: settingsTabId = UUID()
        }
    }

    // MARK: - Tab Item
    
    private func tabItem(_ tab: AppTab, label: LocalizedStringKey, sfSymbol: String) -> some View {
        let isActive = selectedTab == tab
        return Button {
            if isActive {
                resetTab(tab)
            } else {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 5) {
                Spacer(minLength: 0)
                
                if isActive {
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
        memoVM: di.makeMemoViewModel(),
        statsVM: di.makeStatsViewModel(),
        settingsVM: di.makeSettingsViewModel()
    )
}
