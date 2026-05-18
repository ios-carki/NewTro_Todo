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
    let makeBackupLogVM: @MainActor () -> BackupLogViewModel

    // TodoAdd: SwiftUI .sheet 가 키보드 등장 시 .large 로 강제 승격되는 한계 때문에
    // ZStack 안에 NavigationView 단일 오버레이로 직접 그린다.
    // compact ↔ expanded 사이를 같은 view 안에서 morph 하므로
    // AutoFocusTextField(UITextField) 의 identity 가 유지 → 키보드 끊김 없음.
    @StateObject private var todoFormState = TodoFormState()
    @State private var todoAddOpen: Bool = false
    @State private var todoAddExpanded: Bool = false
    // 오버레이를 NavigationView 로 감싸지 않고, 하위 화면(TemplateList / ReminderDatePicker) 은
    // .fullScreenCover 로 띄운다. NavigationView 의 불투명 hosting bg 가 dim 위에 합성되어
    // dim 이 두 배로 진해지고, dismiss 후 onChange 가 다시 발화하지 않는 잔존 상태 문제 회피.
    @State private var showTemplateList: Bool = false
    @State private var showReminderPicker: Bool = false

    var body: some View {
        ZStack {
            // Welcome 배경 (마스코트 제외, 애니메이션 OFF)
            BackgroundSceneryView()
                .ignoresSafeArea()

            // safe area 측정 전용 투명 레이어
            GeometryReader { geo in
                Color.clear
                    .onAppear { safeAreaBottom = geo.safeAreaInsets.bottom }
            }
            .ignoresSafeArea()

            tabContent

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

            // TodoAdd 오버레이 — compact/expanded morph
            // dim 과 panel 을 별도 zIndex 레이어로 분리. NavigationView 미사용 → 합성 dim 두꺼움 회피.
            // expanded 배경 + 패널은 .move(edge: .bottom) 로 키보드와 함께 슬라이드 다운.
            // compact dim 은 슬라이드가 어색해서 fade 유지.
            if todoAddOpen {
                if todoAddExpanded {
                    Color.panel
                        .ignoresSafeArea()
                        .transition(.move(edge: .bottom))
                        .zIndex(28)
                } else {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture { dismissTodoAdd() }
                        .transition(.opacity)
                        .zIndex(28)
                }
                todoAddPanel
                    .zIndex(30)
            }

            // Toast — 단일 렌더 지점. 모든 레이어(인라인 패널 dim 포함) 위에 표시.
            if let msg = mainVM.toastMessage {
                VStack {
                    toastBanner(msg)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Spacer()
                }
                .zIndex(40)
                .allowsHitTesting(false)
            }
        }
        .animation(.easeOut(duration: 0.25), value: mainVM.toastMessage)
        .onChange(of: mainVM.activeSheet?.id) { _ in
            routeActiveSheetChange()
        }
        // 백업·복구 모달은 floatingTabBar 보다 위 레이어에서 렌더링되어야 dim이 탭바까지 덮음.
        .overlay {
            ZStack {
                if settingsVM.backupPhase.isActive {
                    BackupProgressView(
                        phase: .init(settingsVM.backupPhase),
                        titleKey: "데이터 백업",
                        onConfirm: { settingsVM.dismissBackupProgressModal() }
                    )
                    .transition(.opacity)
                    .zIndex(10)
                }
                if settingsVM.restorePhase.isActive {
                    BackupProgressView(
                        phase: .init(settingsVM.restorePhase),
                        titleKey: "데이터 불러오기",
                        onConfirm: { settingsVM.dismissRestoreProgressModal() }
                    )
                    .transition(.opacity)
                    .zIndex(11)
                }
                if let preview = settingsVM.restorePreview {
                    RestorePreviewSheet(
                        header: preview.header,
                        onMerge:     { settingsVM.confirmRestore(mode: .merge) },
                        onOverwrite: { settingsVM.confirmRestore(mode: .overwrite) },
                        onCancel:    { settingsVM.cancelRestorePreview() }
                    )
                    .transition(.opacity)
                    .zIndex(12)
                }
            }
            .animation(.easeOut(duration: 0.15), value: settingsVM.backupPhase)
            .animation(.easeOut(duration: 0.15), value: settingsVM.restorePhase)
            .animation(.easeOut(duration: 0.15), value: settingsVM.restorePreview)
        }
        .sheet(isPresented: $showTemplateList) {
            NavigationStack {
                TemplateListView(viewModel: mainVM)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showReminderPicker) {
            ReminderDatePickerView(
                reminderDate: $todoFormState.reminderDate,
                hasReminder: $todoFormState.hasReminder
            )
            .presentationDetents([.height(420)])
            .presentationDragIndicator(.hidden)
        }
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

    // MARK: - TodoAdd Panel (morph)
    //
    // compact: 화면 하단에 패널이 떠 있고, 위쪽은 dim(별도 zIndex 28) 으로 분리.
    // expanded: 화면 전체에 panel 색 배경(별도 zIndex 28) + 패널이 maxHeight 로 확장.
    // 양쪽 모두 같은 TodoAddOverlayContent 인스턴스를 사용 → AutoFocusTextField identity 보존.
    private var todoAddPanel: some View {
        VStack(spacing: 0) {
            if !todoAddExpanded { Spacer(minLength: 0) }
            TodoAddOverlayContent(
                viewModel: mainVM,
                formState: todoFormState,
                isExpanded: $todoAddExpanded,
                onSave:     { saveFromTodoAdd() },
                onDismiss:  { dismissTodoAdd() },
                onEmptyAttempt: { mainVM.showToast("할 일을 입력하세요".localized()) },
                onShowTemplates: { showTemplateList = true },
                onShowReminder:  { showReminderPicker = true },
                onDelete: {
                    if let id = todoFormState.editingTodo?.id {
                        mainVM.deleteTodo(id: id)
                    }
                    dismissTodoAdd()
                }
            )
            .frame(maxHeight: todoAddExpanded ? .infinity : nil, alignment: .top)
        }
        // 키보드와 동일 타이밍(약 0.25s)으로 슬라이드 다운. expanded 의 X 탭 dismiss 도 동일.
        .transition(.move(edge: .bottom))
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

    // MARK: - TodoAdd Routing

    // MainViewModel.activeSheet 의 .addTodo / .editTodo 를 단일 오버레이로 라우팅.
    // .datePicker 는 MainView 내 .sheet 가 처리.
    private func routeActiveSheetChange() {
        guard let sheet = mainVM.activeSheet else {
            // 외부에서 activeSheet 가 nil 로 비워지는 경로(예: VM 측 강제 dismiss) — 일반 흐름은
            // dismissTodoAdd() 가 이미 처리. 그래도 여기서 안전망 처리 — 키보드 타이밍에 맞춤.
            if todoAddOpen {
                withAnimation(.easeInOut(duration: 0.25)) {
                    todoAddOpen = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    todoAddExpanded = false
                }
            }
            return
        }
        switch sheet {
        case .addTodo:
            todoFormState.reset(for: nil)
            todoAddExpanded = false
            withAnimation(.easeInOut(duration: 0.25)) { todoAddOpen = true }
        case .editTodo(let todo):
            todoFormState.reset(for: todo)
            // 편집은 곧바로 expanded — 세부 항목까지 보여야 의미가 있음.
            todoAddExpanded = true
            withAnimation(.easeInOut(duration: 0.25)) { todoAddOpen = true }
        case .datePicker:
            break
        }
    }

    private func dismissTodoAdd() {
        // 패널 슬라이드 다운과 동시에 키보드 dismiss 트리거.
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
        )
        // 키보드 default animation curve(easeInOut) + duration 0.25s 와 맞추기.
        // todoAddExpanded 는 오버레이가 완전히 사라진 뒤 리셋해 다음 진입 시 잔존 상태 회피.
        withAnimation(.easeInOut(duration: 0.25)) {
            todoAddOpen = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            todoAddExpanded = false
        }
        mainVM.activeSheet = nil
    }

    private func saveFromTodoAdd() {
        guard !todoFormState.isEmpty else { return }
        let trimmed = todoFormState.trimmedText
        let targetTimeStart = todoFormState.resolvedTargetTimeStart
        let notifyAt = todoFormState.resolvedNotifyAt

        if let todo = todoFormState.editingTodo {
            mainVM.editTodo(
                id: todo.id,
                text: trimmed,
                importance: todoFormState.importance,
                targetTimeStart: targetTimeStart,
                targetTimeEnd: nil,
                isAllDay: false,
                notifyAt: notifyAt,
                colorName: todoFormState.colorName
            )
        } else {
            mainVM.addTodo(
                text: trimmed,
                importance: todoFormState.importance,
                targetTimeStart: targetTimeStart,
                targetTimeEnd: nil,
                isAllDay: false,
                notifyAt: notifyAt,
                colorName: todoFormState.colorName
            )
        }
        dismissTodoAdd()
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
            SettingsView(
                viewModel: settingsVM,
                statsVM: statsVM,
                makeBackupLogVM: makeBackupLogVM
            )
            .id(settingsTabId)
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
        settingsVM: di.makeSettingsViewModel(),
        makeBackupLogVM: { di.makeBackupLogViewModel() }
    )
}
