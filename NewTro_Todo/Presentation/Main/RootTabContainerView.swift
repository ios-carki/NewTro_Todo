import SwiftUI

enum AppTab: Equatable {
    case todo, calendar, memo, stats, settings
}

struct RootTabContainerView: View {
    @State private var selectedTab: AppTab = .todo
    @ObservedObject var mainVM: MainViewModel
    @ObservedObject var calendarVM: CalendarViewModel
    @ObservedObject var settingsVM: SettingsViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.sky.ignoresSafeArea()

            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            bottomNavWithGround
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .sheet(isPresented: $mainVM.isQuickNotePresented) {
            QuickNoteSheetView(viewModel: mainVM)
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .todo:
            MainView(
                viewModel: mainVM,
                onCalendarTapped: { selectedTab = .calendar }
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
            PlaceholderTabView(title: "메모")
        case .stats:
            PlaceholderTabView(title: "통계")
        case .settings:
            SettingsView(viewModel: settingsVM)
        }
    }

    // MARK: - Bottom Nav
    // 구조: ink 경계 → 잔디 스트립 → 탭 아이템(흙 배경) → 흙 채움(홈 인디케이터 영역)
    private var bottomNavWithGround: some View {
        VStack(spacing: 0) {
            // 상단 ink 경계
            Color.ink.frame(height: 3)

            // 잔디 타일 스트립
            Canvas { ctx, size in
                let tileW: CGFloat = 10
                var x: CGFloat = 0
                while x < size.width {
                    let c: Color = Int(x / tileW) % 2 == 0 ? .grass : .grassDk
                    ctx.fill(Path(CGRect(x: x, y: 0, width: tileW, height: size.height)), with: .color(c))
                    x += tileW
                }
            }
            .frame(height: 10)
            .frame(maxWidth: .infinity)

            // 탭 아이템 (흙 텍스처 배경)
            HStack(spacing: 0) {
                navItem(label: "할일",  sfIcon: "list.bullet",    isActive: selectedTab == .todo)     { selectedTab = .todo }
                navItem(label: "달력",  sfIcon: "calendar",        isActive: selectedTab == .calendar) { selectedTab = .calendar }
                navItem(label: "메모",  sfIcon: "pencil",          isActive: false)                    { mainVM.openQuickNote() }
                navItem(label: "통계",  sfIcon: "chart.bar.fill",  isActive: selectedTab == .stats)    { selectedTab = .stats }
                navItem(label: "설정",  sfIcon: "gearshape.fill",  isActive: selectedTab == .settings) { selectedTab = .settings }
            }
            .frame(height: 60)
            .background(dirtTile)

            // 홈 인디케이터 영역 흙 채움
            dirtTile.frame(height: 40).frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    private var dirtTile: some View {
        Canvas { ctx, size in
            let tileW: CGFloat = 14
            var x: CGFloat = 0
            while x < size.width {
                let c: Color = Int(x / tileW) % 2 == 0 ? .dirt : .dirtDk
                ctx.fill(Path(CGRect(x: x, y: 0, width: tileW, height: size.height)), with: .color(c))
                x += tileW
            }
        }
    }

    private func navItem(label: String, sfIcon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: sfIcon)
                    .font(.system(size: 15))
                    .foregroundColor(isActive ? .ink : .cream)
                Text(label)
                    .font(.pressStart7())
                    .foregroundColor(isActive ? .ink : .cream)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isActive ? Color.cream : Color.clear)
        }
    }
}

// 탭바 전체 높이: 3 + 10 + 60 + 40 = 113pt
private let tabBarTotalHeight: CGFloat = 113

// MARK: - Placeholder
private struct PlaceholderTabView: View {
    let title: String

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(title)
                .font(.galBold22())
                .foregroundColor(.shade)
            Text("준비 중입니다")
                .font(.pressStart9())
                .foregroundColor(.shade.opacity(0.6))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, tabBarTotalHeight)
    }
}
