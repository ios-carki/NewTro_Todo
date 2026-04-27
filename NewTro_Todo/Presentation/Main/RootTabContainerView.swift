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

    // 탭바 전체 높이: 잔디(13) + 버튼(60) = 73pt (safe area는 별도 처리)
    private let tabBarVisibleHeight: CGFloat = 73

    var body: some View {
        ZStack(alignment: .bottom) {
            // SplashView와 동일한 하늘 배경
            Color.sky.ignoresSafeArea()

            // 콘텐츠: 탭바 높이만큼 하단 여백
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, tabBarVisibleHeight)

            // 탭바 (하단 고정, safe area 위)
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
    // 구조: ink 선(3) + 잔디(10) + 버튼(60) = 73pt visible
    // 흙 배경은 safe area까지 Color로 채움 (Canvas 팽창 방지)

    private var tabBar: some View {
        VStack(spacing: 0) {
            // 상단 ink 선
            Color.ink.frame(height: 3)

            // 잔디 블레이드 (Canvas는 반드시 명시적 frame)
            grassCanvas
                .frame(height: 10)
                .frame(maxWidth: .infinity)

            // 탭 버튼 (흙 배경, Canvas에 명시적 frame)
            HStack(spacing: 0) {
                tabItem(.todo,     label: "할일", sfSymbol: "checkmark.square.fill")
                tabItem(.calendar, label: "달력", sfSymbol: "calendar")
                tabItem(.memo,     label: "메모", sfSymbol: "pencil")
                tabItem(.stats,    label: "통계", sfSymbol: "chart.bar.fill")
                tabItem(.settings, label: "설정", sfSymbol: "gearshape.fill")
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(
                // 명시적 frame으로 Canvas 팽창 차단
                GeometryReader { geo in
                    dirtCanvas.frame(width: geo.size.width, height: geo.size.height)
                }
            )
        }
        // safe area 아래쪽은 Canvas 없이 단색으로 채움
        .background(Color.dirtDk.ignoresSafeArea(edges: .bottom))
        .frame(height: tabBarVisibleHeight)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Tab Item

    private func tabItem(_ tab: AppTab, label: String, sfSymbol: String) -> some View {
        let isActive = selectedTab == tab
        return Button { selectedTab = tab } label: {
            VStack(spacing: 5) {
                Spacer(minLength: 0)

                if isActive {
                    // 공중에 뜬 느낌: sun 박스 + 우하단 픽셀 드롭섀도
                    ZStack {
                        Rectangle()
                            .fill(Color.ink)
                            .frame(width: 40, height: 32)
                            .offset(x: 2, y: 2)
                        Rectangle()
                            .fill(Color.sun)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                            .frame(width: 40, height: 32)
                        Image(systemName: sfSymbol)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.ink)
                    }
                } else {
                    Image(systemName: sfSymbol)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.cream)
                        .frame(width: 40, height: 32)
                }

                Text(label)
                    .font(.galBold14())
                    .foregroundColor(isActive ? .sun : .cream)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Ground Canvases (항상 명시적 frame과 함께 사용)

    private var grassCanvas: some View {
        Canvas { ctx, size in
            // 잔디 바닥
            ctx.fill(
                Path(CGRect(x: 0, y: 3, width: size.width, height: size.height - 3)),
                with: .color(.grass)
            )
            // 명암 패치
            let pw: CGFloat = 8
            var x: CGFloat = 0
            while x < size.width {
                if Int(x / pw) % 2 == 0 {
                    ctx.fill(
                        Path(CGRect(x: x, y: 4, width: pw, height: size.height - 4)),
                        with: .color(.grassDk)
                    )
                }
                x += pw
            }
            // 블레이드 tops
            var bx: CGFloat = 2; var toggle = false
            while bx < size.width {
                let h: CGFloat = toggle ? 4 : 3
                ctx.fill(
                    Path(CGRect(x: bx, y: 0, width: 2, height: h)),
                    with: .color(toggle ? .grass : .grassDk)
                )
                bx += 5; toggle.toggle()
            }
        }
    }

    private var dirtCanvas: some View {
        Canvas { ctx, size in
            let tw: CGFloat = 14
            var x: CGFloat = 0
            while x < size.width {
                let c: Color = Int(x / tw) % 2 == 0 ? .dirt : .dirtDk
                ctx.fill(Path(CGRect(x: x, y: 0, width: tw, height: size.height)), with: .color(c))
                x += tw
            }
        }
    }
}

let tabBarTotalHeight: CGFloat = 73
