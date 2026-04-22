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
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                titleArea
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                todoList
                    .padding(.top, 8)
            }

            fab
                .padding(.bottom, 96)
                .padding(.trailing, 18)
                .frame(maxWidth: .infinity, alignment: .trailing)

            bottomNavWithGround
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

    // MARK: - Top HUD (테두리 없이 sky 위에 플로팅)
    private var topHUD: some View {
        HStack {
            HStack(spacing: 4) {
                PixelArtView(grid: PixelArtAssets.coinGrid, palette: PixelArtAssets.coinPalette, scale: 2.5)
                Text("×\(String(format: "%02d", viewModel.completedCount))")
                    .font(.pressStart10())
                    .foregroundColor(.sun)
            }

            Spacer()

            Text("WORLD \(viewModel.worldDate)")
                .font(.pressStart9())
                .foregroundColor(.ink)

            Spacer()

            HStack(spacing: 4) {
                PixelArtView(grid: PixelArtAssets.heartGrid, palette: PixelArtAssets.heartPalette, scale: 2)
                Text("×\(viewModel.heartCount)")
                    .font(.pressStart10())
                    .foregroundColor(.pixelRed)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Title Area (패널 없이 sky 위에)
    private var titleArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.displayDate)
                        .font(.pressStart12())
                        .foregroundColor(.pinkDk)
                    Text("오늘의 할 일")
                        .font(.galBold22())
                        .foregroundColor(.ink)
                }

                Spacer()

                HStack(spacing: 8) {
                    Button { onCalendarTapped?() } label: {
                        Image(systemName: "calendar")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.ink)
                            .frame(width: 34, height: 34)
                            .background(Color.cream)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                            .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
                    }

                    Button { viewModel.openQuickNote() } label: {
                        Text("MEMO")
                            .font(.pressStart9())
                            .foregroundColor(.ink)
                            .padding(.horizontal, 8)
                            .frame(height: 34)
                            .background(Color.pixelPink)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                            .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
                    }
                }
            }

            PixelProgressBar(done: viewModel.completedCount, total: viewModel.todos.count)
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
                    emptyState.padding(.top, 40)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 180)
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

    // MARK: - Bottom Nav + Ground Strip
    private var bottomNavWithGround: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                navItem(label: "할일",  sfIcon: "list.bullet",      isActive: true)  { }
                navItem(label: "달력",  sfIcon: "calendar",          isActive: false) { onCalendarTapped?() }
                navItem(label: "메모",  sfIcon: "pencil",            isActive: false) { viewModel.openQuickNote() }
                navItem(label: "통계",  sfIcon: "chart.bar.fill",    isActive: false) { }
                navItem(label: "설정",  sfIcon: "gearshape.fill",    isActive: false) { onSettingsTapped?() }
            }
            .frame(height: 60)
            .background(Color.panel)
            .overlay(alignment: .top) { Color.ink.frame(height: 2) }

            GroundStripView()
        }
    }

    private func navItem(label: String, sfIcon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: sfIcon)
                    .font(.system(size: 15))
                    .foregroundColor(isActive ? .ink : .shade)
                Text(label)
                    .font(.pressStart7())
                    .foregroundColor(isActive ? .ink : .shade)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isActive ? Color.sun.opacity(0.35) : Color.clear)
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
                Rectangle().fill(Color.panel)
                Rectangle()
                    .fill(Color.grass)
                    .frame(width: geo.size.width * ratio)
                    .animation(.easeInOut(duration: 0.3), value: ratio)
                Text("\(done)/\(total)")
                    .font(.pressStart9())
                    .foregroundColor(.ink)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 18)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
    }
}
