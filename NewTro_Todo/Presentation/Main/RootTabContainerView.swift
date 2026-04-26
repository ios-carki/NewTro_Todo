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

            // Grass strip with blade tops
            grassStrip

            // Tab buttons on dirt
            HStack(spacing: 0) {
                tabItem(.todo,     label: "할일", icon: PixelArtAssets.tabIconTodo)
                tabItem(.calendar, label: "달력", icon: PixelArtAssets.tabIconCalendar)
                tabItem(.memo,     label: "메모", icon: PixelArtAssets.tabIconMemo)
                tabItem(.stats,    label: "통계", icon: PixelArtAssets.tabIconStats)
                tabItem(.settings, label: "설정", icon: PixelArtAssets.tabIconSettings)
            }
            .frame(height: 60)
            .background(dirtCanvas)

            // Ground base
            dirtCanvas
                .frame(height: 40)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Grass Strip

    private var grassStrip: some View {
        Canvas { ctx, size in
            let w = size.width
            let h = size.height

            // Grass base
            ctx.fill(
                Path(CGRect(x: 0, y: 3, width: w, height: h - 3)),
                with: .color(.grass)
            )

            // Dark patches for depth (alternating 8pt blocks)
            let patchW: CGFloat = 8
            var px: CGFloat = 0
            while px < w {
                if Int(px / patchW) % 2 == 0 {
                    ctx.fill(
                        Path(CGRect(x: px, y: 5, width: patchW, height: h - 5)),
                        with: .color(.grassDk)
                    )
                }
                px += patchW
            }

            // Grass blade tops (staggered every 5pt)
            var bx: CGFloat = 2
            var toggle = false
            while bx < w {
                let bladeH: CGFloat = toggle ? 4 : 3
                ctx.fill(
                    Path(CGRect(x: bx, y: 0, width: 2, height: bladeH)),
                    with: .color(toggle ? .grass : .grassDk)
                )
                bx += 5
                toggle.toggle()
            }
        }
        .frame(height: 12)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Tab Item

    private func tabItem(_ tab: AppTab, label: String, icon: [String]) -> some View {
        let isActive = selectedTab == tab
        return Button { selectedTab = tab } label: {
            VStack(spacing: 0) {
                Spacer(minLength: 4)

                // Pixel art icon
                PixelTabIcon(grid: icon, isActive: isActive)

                Spacer(minLength: 3)

                // Label
                Text(label)
                    .font(.pressStart7())
                    .foregroundColor(isActive ? .ink : .cream)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Spacer(minLength: 4)

                // 3-dot active indicator
                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle()
                            .fill(isActive ? Color.sun : Color.clear)
                            .frame(width: 3, height: 3)
                    }
                }

                Spacer(minLength: 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(tabBackground(isActive: isActive))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func tabBackground(isActive: Bool) -> some View {
        if isActive {
            ZStack {
                // Pixel-art shadow (ink offset block)
                Color.ink
                    .padding(.top, 2)
                    .padding(.leading, 2)

                // Main cream block with ink border
                Color.cream
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    .padding(.bottom, 2)
                    .padding(.trailing, 2)
            }
        } else {
            Color.clear
        }
    }

    // MARK: - Dirt Canvas

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
            // Subtle top highlight line
            ctx.fill(
                Path(CGRect(x: 0, y: 0, width: size.width, height: 1)),
                with: .color(.ink.opacity(0.15))
            )
        }
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
        let iconColor: Color = isActive ? .ink : .cream

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
                    ctx.fill(Path(rect), with: .color(iconColor))
                }
            }
        }
        .frame(width: cols * pixelSize, height: rows * pixelSize)
    }
}

// Keep the constant for padding references elsewhere
let tabBarTotalHeight: CGFloat = 115
