import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    @AppStorage("selectedCharacterId") private var selectedCharacterId: String = "pinko"

    private var selectedCharInfo: FriendCharInfo {
        CharacterData.all.first { $0.id == selectedCharacterId } ?? CharacterData.all[0]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.sky.ignoresSafeArea()

            VStack(spacing: 0) {
                topHUD
                    .padding(.horizontal, 16)

                titleArea
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                todoList
                    .padding(.top, 8)
            }
        }
        .sheet(isPresented: $viewModel.isAddTodoPresented) {
            TodoAddView(viewModel: viewModel)
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

    // MARK: - Title Area
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

                Button { viewModel.presentAddTodo() } label: {
                    Text("+ Todo")
                        .font(.pressStart9())
                        .foregroundColor(.ink)
                        .padding(.horizontal, 8)
                        .frame(height: 34)
                        .background(Color.pixelPink)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
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
            PixelPanel(bg: .cream, padding: 16) {
                VStack(spacing: 10) {
                    BobbingCharView(info: selectedCharInfo)
                    Text("오늘은 할 일이 없어요")
                        .font(.galBold14())
                        .foregroundColor(.ink)
                    Text("★ 버튼으로 추가해보세요!")
                        .font(.pressStart7())
                        .foregroundColor(.shade.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
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

#Preview { @MainActor in
    let di = DIContainer()
    return MainView(viewModel: di.makeMainViewModel())
}
