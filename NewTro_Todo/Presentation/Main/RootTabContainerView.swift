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
    // 구조: ink 상단 선 → 잔디 블레이드(10pt) → 탭 버튼 (흙 배경)

    private var tabBar: some View {
        ZStack(alignment: .top) {
            // 흙 배경 — safe area까지 채움
            dirtCanvas
                .ignoresSafeArea(edges: .bottom)

            VStack(spacing: 0) {
                // 상단 ink 선
                Color.ink.frame(height: 3)

                // 잔디 블레이드
                grassCanvas.frame(height: 10)

                // 탭 버튼들
                HStack(spacing: 0) {
                    tabItem(.todo,     label: "할일", sfSymbol: "checkmark.square.fill")
                    tabItem(.calendar, label: "달력", sfSymbol: "calendar")
                    tabItem(.memo,     label: "메모", sfSymbol: "pencil")
                    tabItem(.stats,    label: "통계", sfSymbol: "chart.bar.fill")
                    tabItem(.settings, label: "설정", sfSymbol: "gearshape.fill")
                }
                .frame(height: 62)
            }
        }
    }

    // MARK: - Tab Item

    private func tabItem(_ tab: AppTab, label: String, sfSymbol: String) -> some View {
        let isActive = selectedTab == tab
        return Button { selectedTab = tab } label: {
            VStack(spacing: 5) {
                Spacer(minLength: 0)

                if isActive {
                    // Sun 박스 + 우하단 픽셀 드롭섀도
                    ZStack {
                        Rectangle()
                            .fill(Color.ink)
                            .frame(width: 40, height: 34)
                            .offset(x: 2, y: 2)
                        Rectangle()
                            .fill(Color.sun)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                            .frame(width: 40, height: 34)
                        Image(systemName: sfSymbol)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.ink)
                    }
                } else {
                    Image(systemName: sfSymbol)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.cream)
                        .frame(width: 40, height: 34)
                }

                Text(label)
                    .font(.galBold14())
                    .foregroundColor(isActive ? .sun : .cream)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 62)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Ground Canvases

    private var grassCanvas: some View {
        Canvas { ctx, size in
            // 잔디 바닥
            ctx.fill(
                Path(CGRect(x: 0, y: 3, width: size.width, height: size.height - 3)),
                with: .color(.grass)
            )
            // 명암 패치
            let patchW: CGFloat = 8
            var px: CGFloat = 0
            while px < size.width {
                if Int(px / patchW) % 2 == 0 {
                    ctx.fill(
                        Path(CGRect(x: px, y: 4, width: patchW, height: size.height - 4)),
                        with: .color(.grassDk)
                    )
                }
                px += patchW
            }
            // 블레이드 tops
            var bx: CGFloat = 2
            var toggle = false
            while bx < size.width {
                let h: CGFloat = toggle ? 4 : 3
                ctx.fill(
                    Path(CGRect(x: bx, y: 0, width: 2, height: h)),
                    with: .color(toggle ? .grass : .grassDk)
                )
                bx += 5
                toggle.toggle()
            }
        }
    }

    private var dirtCanvas: some View {
        Canvas { ctx, size in
            let tileW: CGFloat = 14
            var x: CGFloat = 0
            while x < size.width {
                let c: Color = Int(x / tileW) % 2 == 0 ? .dirt : .dirtDk
                ctx.fill(
                    Path(CGRect(x: x, y: 0, width: tileW, height: size.height)),
                    with: .color(c)
                )
                x += tileW
            }
        }
    }
}

let tabBarTotalHeight: CGFloat = 75  // 3 + 10 + 62
