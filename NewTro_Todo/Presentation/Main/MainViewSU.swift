import SwiftUI

struct MainView: View {
    @StateObject var viewModel: MainViewModel
    var onCalendarTapped: (() -> Void)?
    var onSettingsTapped: (() -> Void)?

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.sky.ignoresSafeArea()

            VStack(spacing: 0) {
                topHUD
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                titleArea
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                todoList
                    .padding(.top, 8)
            }

            bottomNav

            fab
                .padding(.bottom, 72)
                .padding(.trailing, 18)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $viewModel.isQuickNotePresented) {
            QuickNoteSheetView(viewModel: viewModel)
        }
        .sheet(item: $viewModel.actionTarget) { todo in
            TodoActionMenuView(todo: todo, viewModel: viewModel)
        }
        .sheet(item: $viewModel.postponeTarget) { todo in
            PostponeMenuView(todo: todo, viewModel: viewModel)
        }
        .alert("오류", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("확인") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear { viewModel.loadTodos() }
    }

    // MARK: - Top HUD
    private var topHUD: some View {
        HStack(spacing: 0) {
            HStack(spacing: 4) {
                PixelArtView(grid: PixelArtAssets.coinGrid, palette: PixelArtAssets.coinPalette, scale: 2.5)
                Text(String(format: "%02d", viewModel.completedCount))
                    .font(.pressStart10())
                    .foregroundColor(.sun)
            }

            Spacer()

            Text("WORLD \(viewModel.worldDate)")
                .font(.pressStart9())
                .foregroundColor(.ink)

            Spacer()

            HStack(spacing: 2) {
                ForEach(0..<viewModel.heartCount, id: \.self) { _ in
                    PixelArtView(grid: PixelArtAssets.heartGrid, palette: PixelArtAssets.heartPalette, scale: 2)
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.cream)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
    }

    // MARK: - Title Area
    private var titleArea: some View {
        PixelPanel(bg: .panel, padding: 12) {
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.worldDate)
                            .font(.pressStart9())
                            .foregroundColor(.pinkDk)
                        Text("오늘의 할일")
                            .font(.galBold22())
                            .foregroundColor(.ink)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        Button { onCalendarTapped?() } label: {
                            PixelIconButton(label: "CAL", bg: .cream)
                        }
                        Button { viewModel.openQuickNote() } label: {
                            PixelIconButton(label: "MEMO", bg: Color.pixelPink.opacity(0.7))
                        }
                    }
                }

                PixelProgressBar(
                    done: viewModel.completedCount,
                    total: viewModel.todos.count
                )
            }
        }
    }

    // MARK: - Todo List
    private var todoList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(viewModel.todos, id: \.id) { todo in
                    TodoRowView(todo: todo, viewModel: viewModel)
                }

                if viewModel.todos.isEmpty {
                    emptyState
                        .padding(.top, 40)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 160)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            PixelArtView(grid: PixelArtAssets.mascotGrid, palette: PixelArtAssets.mascotPalette, scale: 3)
            Text("할일이 없어요!")
                .font(.galBold16())
                .foregroundColor(.shade)
            Text("+ 버튼으로 추가해보세요")
                .font(.pressStart9())
                .foregroundColor(.shade.opacity(0.7))
        }
    }

    // MARK: - FAB
    private var fab: some View {
        Button { viewModel.addTodo() } label: {
            Text("+")
                .font(.pressStart20())
                .foregroundColor(.ink)
                .frame(width: 48, height: 48)
                .background(Color.peach)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 3))
                .background(Rectangle().fill(Color.ink).offset(x: 4, y: 4))
        }
    }

    // MARK: - Bottom Nav
    private var bottomNav: some View {
        HStack(spacing: 0) {
            navItem(label: "TODO", icon: PixelArtAssets.checkGrid, palette: PixelArtAssets.checkPalette, isActive: true) {}
            navItem(label: "CAL", icon: PixelArtAssets.starGrid, palette: PixelArtAssets.starPalette, isActive: false) { onCalendarTapped?() }
            navItem(label: "MEMO", icon: PixelArtAssets.coinGrid, palette: PixelArtAssets.coinPalette, isActive: false) { viewModel.openQuickNote() }
            navItem(label: "SET", icon: PixelArtAssets.starGrid, palette: PixelArtAssets.starPalette, isActive: false) { onSettingsTapped?() }
        }
        .frame(height: 60)
        .background(Color.panel)
        .overlay(alignment: .top) { Color.ink.frame(height: 3) }
    }

    private func navItem(label: String, icon: [String], palette: [Character: Color], isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                PixelArtView(grid: icon, palette: palette, scale: 1.5)
                Text(label)
                    .font(.pressStart7())
                    .foregroundColor(isActive ? .ink : .shade)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isActive ? Color.sun.opacity(0.3) : Color.clear)
        }
    }
}

// MARK: - PixelProgressBar
private struct PixelProgressBar: View {
    let done: Int
    let total: Int

    private var ratio: CGFloat {
        total == 0 ? 0 : min(CGFloat(done) / CGFloat(total), 1)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle().fill(Color.ink.opacity(0.1))
                Rectangle()
                    .fill(Color.grass)
                    .frame(width: geo.size.width * ratio)
                    .animation(.easeInOut(duration: 0.3), value: ratio)
            }
        }
        .frame(height: 10)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .overlay(alignment: .trailing) {
            Text("\(done)/\(total)")
                .font(.pressStart7())
                .foregroundColor(.ink)
                .padding(.trailing, 4)
        }
    }
}

// MARK: - PixelIconButton
private struct PixelIconButton: View {
    let label: String
    let bg: Color

    var body: some View {
        Text(label)
            .font(.pressStart7())
            .foregroundColor(.ink)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(bg)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
    }
}
