import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    @AppStorage("selectedCharacterId") private var selectedCharacterId: String = "pinko"
    @State private var editMode: EditMode = .inactive
    @State private var previousSheetId: String? = nil

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
        .sheet(item: $viewModel.activeSheet) { sheet in
            switch sheet {
            case .addTodo:
                TodoAddSheetWrapper(viewModel: viewModel)
            case .editTodo(let todo):
                TodoAddSheetWrapper(viewModel: viewModel, editingTodo: todo)
            case .actionMenu(let todo):
                TodoActionMenuView(todo: todo, viewModel: viewModel)
                    .interactiveDismissDisabled(true)
                    .presentationDragIndicator(.hidden)
            case .postpone(let todo):
                PostponeMenuView(todo: todo, viewModel: viewModel)
            case .datePicker:
                DatePickerSheetView { date in
                    viewModel.navigateToDate(date)
                }
            }
        }
        .onChange(of: viewModel.activeSheet?.id) { newId in
            defer { previousSheetId = newId }
            if newId == nil && previousSheetId?.hasPrefix("actionMenu") == true {
                viewModel.onActionMenuDismissed()
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
        .overlay(alignment: .top) {
            if let msg = viewModel.toastMessage {
                toastBanner(msg)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onAppear { viewModel.loadTodos() }
    }

    // MARK: - Toast Banner
    private func toastBanner(_ message: String) -> some View {
        HStack(spacing: 6) {
            Text("!")
                .font(.pressStart9())
                .foregroundColor(.cream)
            Text(message)
                .font(.galBold14())
                .foregroundColor(.cream)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.shade)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
        .padding(.horizontal, 24)
        .padding(.top, 8)
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

                Button { viewModel.presentDatePicker() } label: {
                    Text("📅")
                        .font(.system(size: 16))
                        .frame(width: 34, height: 34)
                        .background(Color.cream)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        editMode = editMode == .active ? .inactive : .active
                    }
                } label: {
                    Text(editMode == .active ? "완료" : "순서")
                        .font(.pressStart7())
                        .foregroundColor(.ink)
                        .padding(.horizontal, 6)
                        .frame(height: 34)
                        .background(editMode == .active ? Color.grass.opacity(0.4) : Color.cream)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
                }

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

    private var incompleteTodos: [TodoEntity] { viewModel.todos.filter { !$0.isCompleted } }
    private var completedTodos: [TodoEntity] { viewModel.todos.filter { $0.isCompleted } }

    private var todoList: some View {
        Group {
            if viewModel.todos.isEmpty {
                ScrollView {
                    emptyState.padding(.top, 40).padding(.horizontal, 16)
                }
            } else {
                List {
                    ForEach(incompleteTodos, id: \.id) { todo in
                        TodoRowView(todo: todo, viewModel: viewModel)
                            .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .onMove { from, to in
                        viewModel.reorderTodos(from: from, to: to)
                    }

                    ForEach(completedTodos, id: \.id) { todo in
                        TodoRowView(todo: todo, viewModel: viewModel)
                            .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }

                    Color.clear.frame(height: 160)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .environment(\.editMode, $editMode)
            }
        }
        .padding(.top, 8)
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

// MARK: - TodoAdd Sheet Wrapper

private struct TodoAddSheetWrapper: View {
    @ObservedObject var viewModel: MainViewModel
    var editingTodo: TodoEntity? = nil
    @State private var selectedDetent: PresentationDetent = .height(400)
    @State private var compactHeight: CGFloat = 400

    private func templateNav(_ dest: TemplateNavDest) -> some View {
        switch dest {
        case .templateList:      AnyView(TemplateListView(viewModel: viewModel))
        case .newTemplate:       AnyView(TemplateFormView(viewModel: viewModel, editingTemplate: nil))
        case .editTemplate(let t): AnyView(TemplateFormView(viewModel: viewModel, editingTemplate: t))
        }
    }

    var body: some View {
        NavigationStack {
            TodoAddView(viewModel: viewModel, editingTodo: editingTodo, selectedDetent: $selectedDetent)
                .navigationDestination(for: TemplateNavDest.self) { templateNav($0) }
        }
        .presentationDetents([.height(compactHeight), .large], selection: $selectedDetent)
        .presentationDragIndicator(.visible)
        .onPreferenceChange(TodoAddScrollHeightKey.self) { scrollH in
            guard scrollH > 0, selectedDetent != .large else { return }
            let clamped = min(max(scrollH, 320), 520)
            if abs(clamped - compactHeight) > 4 {
                compactHeight = clamped
                selectedDetent = .height(clamped)
            }
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
