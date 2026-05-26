import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    @AppStorage("selectedCharacterId") private var selectedCharacterId: String = "pinko"
    @State private var editMode: EditMode = .inactive

    private var selectedCharInfo: FriendCharInfo {
        CharacterData.all.first { $0.id == selectedCharacterId } ?? CharacterData.all[0]
    }

    // .addTodo / .editTodo 는 상위(RootTabContainerView)가 인라인 패널/풀스크린으로 처리하므로
    // 여기 .sheet 바인딩에서는 걸러낸다. nil 로 set 되는 경우만 VM 상태도 같이 정리.
    private var nonTodoAddActiveSheetBinding: Binding<MainActiveSheet?> {
        Binding<MainActiveSheet?>(
            get: {
                guard let s = viewModel.activeSheet else { return nil }
                switch s {
                case .datePicker:         return s
                case .addTodo, .editTodo: return nil
                }
            },
            set: { newValue in
                guard newValue == nil else { return }
                // 현재 표시 중인 시트가 datePicker 일 때만 클리어 → addTodo 흐름 보호.
                switch viewModel.activeSheet {
                case .datePicker: viewModel.activeSheet = nil
                default: break
                }
            }
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) { FloatingTabBar() }
        // .addTodo / .editTodo 는 RootTabContainerView 의 인라인 패널 + .fullScreenCover 로 라우팅.
        // 여기서는 .datePicker 만 SwiftUI .sheet 로 처리.
        .sheet(item: nonTodoAddActiveSheetBinding) { sheet in
            switch sheet {
            case .datePicker:
                DatePickerSheetView(
                    initialDate: viewModel.selectedDate,
                    monthOverviewProvider: { y, m in
                        await viewModel.fetchMonthOverview(year: y, month: m)
                    },
                    dayStatsProvider: { date in
                        await viewModel.fetchDayPreviewStats(for: date)
                    },
                    onDateConfirmed: { date in
                        viewModel.navigateToDate(date)
                    }
                )
            case .addTodo, .editTodo:
                // 이 분기로는 오지 않음 — 바인딩에서 nil 처리.
                EmptyView()
            }
        }
        .alert("오류", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("확인") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            viewModel.loadTodos()
        }
    }

    // MARK: - Top HUD
    private var topHUD: some View {
        HStack {
            HStack(spacing: 4) {
                PixelArtView(grid: PixelArtAssets.coinGrid, palette: PixelArtAssets.coinPalette, scale: 2.5)
                Text("×\(viewModel.walletBalance)")
                    .font(.pressStart10())
                    .foregroundColor(.sun)
            }
            .coachmarkAnchor("hud_coin")

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
            .coachmarkAnchor("hud_heart")
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
                    Text(viewModel.headerTitle)
                        .font(.galBold22())
                        .foregroundColor(.ink)
                }

                Spacer()

                Button { viewModel.presentDatePicker() } label: {
                    Text("WARP")
                        .font(.pressStart9())
                        .foregroundColor(.ink)
                        .padding(.horizontal, 6)
                        .frame(height: 34)
                        .background(Color.cream)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
                }
                .coachmarkAnchor("warp")

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        editMode = editMode == .active ? .inactive : .active
                    }
                } label: {
                    HStack(spacing: 4) {
                        if editMode == .active {
                            PixelArtView(
                                grid: PixelArtAssets.smallCheckGrid,
                                palette: PixelArtAssets.smallCheckPalette,
                                scale: 2
                            )
                            Text("DONE")
                                .font(.pressStart9())
                                .foregroundColor(.ink)
                        } else {
                            PixelArtView(
                                grid: PixelArtAssets.arrowUpDownGrid,
                                palette: PixelArtAssets.arrowUpDownPalette,
                                scale: 2
                            )
                            Text("SORT")
                                .font(.pressStart9())
                                .foregroundColor(.ink)
                        }
                    }
                    .padding(.horizontal, 6)
                    .frame(height: 34)
                    .background(editMode == .active ? Color.grass.opacity(0.4) : Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
                }
                .coachmarkAnchor("sort")

                Button { viewModel.presentAddTodo() } label: {
                    Text("+ Todo")
                        .font(.pressStart9())
                        .foregroundColor(viewModel.isViewingPastDate ? .shade.opacity(0.5) : .ink)
                        .padding(.horizontal, 8)
                        .frame(height: 34)
                        .background(viewModel.isViewingPastDate ? Color.panel : Color.pixelPink)
                        .overlay(Rectangle().stroke(viewModel.isViewingPastDate ? Color.ink.opacity(0.3) : Color.ink, lineWidth: 2))
                        .background(Rectangle().fill(Color.ink.opacity(viewModel.isViewingPastDate ? 0.3 : 1)).offset(x: 2, y: 2))
                }
                .disabled(viewModel.isViewingPastDate)
                .accessibilityIdentifier("addTodoButton")
                .coachmarkAnchor("add_todo")
            }

            PixelProgressBar(done: viewModel.completedCount, total: viewModel.todos.count)
        }
    }

    // MARK: - Todo List

    private var favoriteIncompleteTodos: [TodoEntity] {
        viewModel.todos.filter { !$0.isCompleted && $0.isFavorite }
    }
    private var nonFavoriteIncompleteTodos: [TodoEntity] {
        viewModel.todos.filter { !$0.isCompleted && !$0.isFavorite }
    }
    private var completedTodos: [TodoEntity] {
        viewModel.todos.filter { $0.isCompleted }
    }

    private var todoList: some View {
        Group {
            if viewModel.todos.isEmpty {
                ScrollView {
                    emptyState.padding(.top, 40).padding(.horizontal, 16)
                }
            } else {
                List {
                    if !favoriteIncompleteTodos.isEmpty {
                        Section {
                            sectionDivider("★ STAR", section: .favorites)
                            if !isSectionCollapsed(.favorites) {
                                ForEach(favoriteIncompleteTodos, id: \.id) { todo in
                                    todoRow(todo)
                                }
                                .onMove { from, to in
                                    viewModel.reorderFavorites(from: from, to: to)
                                }
                            }
                        }
                        .listSectionSeparator(.hidden)
                    }

                    if !nonFavoriteIncompleteTodos.isEmpty {
                        Section {
                            sectionDivider("TODO", section: .todo)
                            if !isSectionCollapsed(.todo) {
                                ForEach(nonFavoriteIncompleteTodos, id: \.id) { todo in
                                    todoRow(todo)
                                }
                                .onMove { from, to in
                                    viewModel.reorderNonFavorites(from: from, to: to)
                                }
                            }
                        }
                        .listSectionSeparator(.hidden)
                    }

                    if !completedTodos.isEmpty {
                        Section {
                            sectionDivider("DONE", section: .done)
                            if !isSectionCollapsed(.done) {
                                ForEach(completedTodos, id: \.id) { todo in
                                    todoRow(todo)
                                }
                            }
                        }
                        .listSectionSeparator(.hidden)
                    }

                    Color.clear.frame(height: 160)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                }
                .listStyle(.plain)
                .environment(\.editMode, $editMode)
            }
        }
        .padding(.top, 8)
    }

    /// SORT(편집) 모드에서는 접힘 무시 — 모든 그룹 펼쳐 드래그 가능하게
    private func isSectionCollapsed(_ section: TodoSection) -> Bool {
        if editMode == .active { return false }
        return viewModel.isCollapsed(section)
    }

    private func todoRow(_ todo: TodoEntity) -> some View {
        TodoRowView(todo: todo, viewModel: viewModel)
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }

    private func sectionDivider(_ title: String, section: TodoSection) -> some View {
        let collapsed = viewModel.isCollapsed(section)
        let editing = editMode == .active
        return HStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    viewModel.toggleCollapse(section)
                }
            } label: {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.pressStart9())
                    Text(collapsed ? "▶" : "▼")
                        .font(.pressStart9())
                        .opacity(editing ? 0.35 : 1)
                }
                .foregroundColor(.ink)
                .padding(.horizontal, 8)
                .frame(height: 24)
                .background(Color.cream)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
            }
            .buttonStyle(.borderless)
            .disabled(editing)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .moveDisabled(true)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            PixelPanel(bg: .cream, padding: 16) {
                VStack(spacing: 10) {
                    BobbingCharView(info: selectedCharInfo)
                    Text(viewModel.isViewingPastDate ? "기록이 남아있지 않아요" : "오늘은 할 일이 없어요")
                        .font(.galBold14())
                        .foregroundColor(.ink)
                    Text(viewModel.isViewingPastDate ? "조용히 지나간 하루였나봐요" : "Todo 작성 버튼으로 추가해보세요!")
                        .font(.galBold11())
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
