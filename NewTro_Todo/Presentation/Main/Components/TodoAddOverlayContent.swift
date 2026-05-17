import SwiftUI

// 인라인(compact) ↔ 풀스크린(expanded) 을 *같은 view* 안에서 morph.
// .fullScreenCover 로 갈아끼우면 새 UIViewController 가 present 되면서 UITextField first responder 가
// 끊어졌다 재바인딩 → 키보드 hide/show 깜빡임. 같은 VStack 의 같은 위치에 textInputRow 를 두면
// SwiftUI 가 view identity 를 유지 → 동일 UITextField 인스턴스 → 키보드 끊김 없음.
struct TodoAddOverlayContent: View {
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var formState: TodoFormState
    @Binding var isExpanded: Bool

    var onSave: () -> Void
    var onDismiss: () -> Void
    var onEmptyAttempt: () -> Void
    var onShowTemplates: () -> Void
    var onShowReminder: () -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            // 위치 0: 헤더 (compact: drag handle, expanded: topBar) — if/else 라 identity 분리되어도 무방.
            if isExpanded {
                topBar
            } else {
                dragHandle
                    .padding(.top, 8)
                    .padding(.bottom, 6)
            }

            // 위치 1: TextField — compact/expanded 양쪽에서 동일 위치 → identity 보존 → keyboard 유지.
            textInputRow
                .padding(.horizontal, 16)
                .padding(.top, isExpanded ? 4 : 0)
                .padding(.bottom, isExpanded ? 0 : 10)

            // 위치 2: 본문 — compact: 짧은 듀로우+세부버튼 / expanded: 스크롤 섹션.
            if isExpanded {
                ScrollView(showsIndicators: false) {
                    expandedSections
                }
                .scrollDismissesKeyboard(.interactively)
            } else {
                compactDueRow
                    .padding(.horizontal, 16)

                expandButton
                    .padding(.top, 4)
                    .padding(.bottom, 12)
            }
        }
        // 컨테이너 측에서 .frame 으로 compact/expanded 최대 높이 결정.
        .frame(maxWidth: .infinity, alignment: .top)
        .background(
            Color.panel
                .overlay(
                    // expanded 일 때는 풀스크린이라 상단 경계선이 필요 없음.
                    Group {
                        if !isExpanded {
                            Rectangle()
                                .fill(Color.ink)
                                .frame(height: 2)
                        }
                    },
                    alignment: .top
                )
        )
        .offset(y: isExpanded ? 0 : dragOffset)
        .gesture(
            // 스와이프 다운 dismiss 는 compact 한정. expanded 에선 ScrollView 와 충돌 우려.
            isExpanded ? nil : compactDragGesture
        )
        .onChange(of: viewModel.pendingTemplate) { template in
            guard let t = template else { return }
            formState.applyTemplate(t)
            viewModel.pendingTemplate = nil
        }
    }

    // MARK: - Compact drag-to-dismiss
    private var compactDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    dragOffset = value.translation.height
                }
            }
            .onEnded { value in
                if value.translation.height > 60 {
                    onDismiss()
                } else {
                    withAnimation(.easeOut(duration: 0.2)) { dragOffset = 0 }
                }
            }
    }

    // MARK: - Drag Handle
    private var dragHandle: some View {
        Rectangle()
            .fill(Color.ink.opacity(0.35))
            .frame(width: 36, height: 3)
    }

    // MARK: - Top Bar (Expanded)
    private var topBar: some View {
        ZStack {
            HStack {
                PxXIcon { onDismiss() }
                Spacer()
                PxCheckIcon(disabled: formState.isEmpty) { onSave() }
            }

            Text(formState.isEditMode ? "할 일 수정" : "새 할 일")
                .font(.galBold17())
                .foregroundColor(.ink)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: - Text Input
    private var textInputRow: some View {
        HStack(spacing: 8) {
            AutoFocusTextField(
                text: $formState.text,
                placeholder: NSLocalizedString("할 일을 입력하세요", comment: "Todo input placeholder"),
                autoFocus: !formState.isEditMode,
                font: UIFont.boldFont(size: 14),
                textColor: UIColor(Color.ink),
                placeholderColor: UIColor(Color.ink).withAlphaComponent(0.4),
                accessibilityIdentifier: "todoTextField",
                onSubmit: {
                    if formState.isEmpty {
                        onEmptyAttempt()
                        return false
                    }
                    onSave()
                    return true
                }
            )
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(Color.cream)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
    }

    // MARK: - Compact 기한 row
    private var compactDueRow: some View {
        HStack(spacing: 8) {
            Text("⌛").font(.system(size: 16))
            Text(formState.hasDueDate ? compactDueDateLabel(formState.dueDate) : "기한")
                .font(.galBold14())
                .foregroundColor(formState.hasDueDate ? .ink : .shade)
            Spacer()
            PxSwitch(isOn: formState.hasDueDate) {
                formState.hasDueDate.toggle()
                if formState.hasDueDate {
                    if formState.dueDate < Calendar.current.startOfDay(for: Date()) {
                        formState.dueDate = Calendar.current.startOfDay(for: Date())
                        formState.dueChip = .today
                        formState.dueCustomOpen = false
                    }
                } else {
                    formState.dueCustomOpen = false
                }
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
    }

    private func compactDueDateLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "yyyy.M.d(EEE)"
        return f.string(from: date) + "까지"
    }

    // MARK: - Expand Button
    private var expandButton: some View {
        Button {
            // 키보드 유지된 상태로 isExpanded 만 토글 → 같은 TextField 가 위치만 morph.
            withAnimation(.easeInOut(duration: 0.25)) { isExpanded = true }
        } label: {
            HStack(spacing: 4) {
                Text("세부 항목")
                    .font(.galBold13())
                    .foregroundColor(.shade)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.shade)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 24)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Expanded Sections
    private var expandedSections: some View {
        VStack(spacing: 0) {
            sectionLabel("템플릿")
            templatesLink
                .padding(.horizontal, 16)

            sectionLabel("기한")
            dueSection
                .padding(.horizontal, 16)

            sectionLabel("중요도")
            importanceSection
                .padding(.horizontal, 16)

            sectionLabel("알림")
            reminderSection
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
        }
    }

    private func sectionLabel(_ title: LocalizedStringKey) -> some View {
        HStack {
            Text(title)
                .font(.galCondensed16())
                .foregroundColor(.shade)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 6)
    }

    // MARK: - Templates Link
    // NavigationLink 대신 callback. RootTabContainerView 가 .fullScreenCover 로 TemplateListView 를 띄움.
    // 오버레이 자체가 NavigationView 안에 있지 않아도 되어 dim 합성 문제와 second-tap 무응답을 회피.
    private var templatesLink: some View {
        Button {
            hideKeyboard()
            onShowTemplates()
        } label: {
            HStack {
                Text("저장된 템플릿")
                    .font(.galBold14())
                    .foregroundColor(.ink)
                Spacer()
                HStack(spacing: 4) {
                    Text("목록 보기")
                        .font(.galBold13())
                        .foregroundColor(.shade)
                    PixelArtView(
                        grid: PixelArtAssets.dotChevronRightGrid,
                        palette: PixelArtAssets.dotChevronRightPalette,
                        scale: 2
                    )
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(Color.cream)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    // MARK: - 기한 (Expanded)
    private var dueSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Text("⌛").font(.system(size: 16))
                    Text("기한").font(.galBold14()).foregroundColor(.ink)
                }
                Spacer()
                PxSwitch(isOn: formState.hasDueDate) {
                    hideKeyboard()
                    formState.hasDueDate.toggle()
                    if formState.hasDueDate {
                        if formState.dueDate < Calendar.current.startOfDay(for: Date()) {
                            formState.dueDate = Calendar.current.startOfDay(for: Date())
                            formState.dueChip = .today
                            formState.dueCustomOpen = false
                        }
                    } else {
                        formState.dueCustomOpen = false
                    }
                }
            }

            if formState.hasDueDate {
                Text(dueDateLabel(formState.dueDate))
                    .font(.pressStart9())
                    .foregroundColor(.ink)
                    .padding(.horizontal, 12)
                    .frame(height: 32)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))

                dueChipsRow

                if formState.dueCustomOpen {
                    PixelDateWheel(
                        date: $formState.dueDate,
                        mode: .date,
                        minimumDate: Calendar.current.startOfDay(for: Date())
                    )
                }
            }
        }
    }

    private var dueChipsRow: some View {
        HStack(spacing: 6) {
            dueChipButton("오늘", chip: .today) {
                formState.dueDate = Calendar.current.startOfDay(for: Date())
                formState.dueChip = .today
                formState.dueCustomOpen = false
            }
            dueChipButton("내일", chip: .tomorrow) {
                let today = Calendar.current.startOfDay(for: Date())
                formState.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
                formState.dueChip = .tomorrow
                formState.dueCustomOpen = false
            }
            dueChipButton("다음주", chip: .nextWeek) {
                let today = Calendar.current.startOfDay(for: Date())
                formState.dueDate = Calendar.current.date(byAdding: .day, value: 7, to: today) ?? today
                formState.dueChip = .nextWeek
                formState.dueCustomOpen = false
            }
            dueChipButton("직접 설정", chip: .custom) {
                formState.dueChip = .custom
                formState.dueCustomOpen.toggle()
            }
        }
    }

    private func dueChipButton(_ title: LocalizedStringKey, chip: TodoFormState.DueChip, onTap: @escaping () -> Void) -> some View {
        let isActive = (formState.dueChip == chip)
        return Button {
            hideKeyboard()
            onTap()
        } label: {
            Text(title)
                .font(.galBold13())
                .foregroundColor(.ink)
                .padding(.horizontal, 10)
                .frame(height: 30)
                .background(isActive ? Color.sun : Color.cream)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Importance
    private var importanceSection: some View {
        HStack(spacing: 0) {
            importanceChip(.none,   label: "낮음")
            importanceChip(.medium, label: "보통")
            importanceChip(.high,   label: "높음")
        }
    }

    private func importanceChip(_ imp: Importance, label: LocalizedStringKey) -> some View {
        let isSelected = formState.importance == imp
        let chipColor: Color = switch imp {
        case .none:   .grass
        case .medium: .sun
        case .high:   .pixelRed
        }
        return Button {
            hideKeyboard()
            formState.importance = imp
        } label: {
            Text(label)
                .font(.galCondensed16())
                .foregroundColor(isSelected ? .cream : .ink)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(isSelected ? chipColor : Color.cream)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    // MARK: - 알림
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Text("🔔").font(.system(size: 16))
                    Text("알림").font(.galBold14()).foregroundColor(.ink)
                }
                Spacer()
                PxSwitch(isOn: formState.hasReminder) {
                    hideKeyboard()
                    formState.hasReminder.toggle()
                    if formState.hasReminder {
                        if formState.reminderDate < Date() {
                            formState.reminderDate = ReminderDatePickerView.defaultReminderDate()
                        }
                    }
                }
            }

            if formState.hasReminder {
                Button {
                    hideKeyboard()
                    onShowReminder()
                } label: {
                    HStack {
                        Text(reminderLabel(formState.reminderDate))
                            .font(.pressStart9())
                            .foregroundColor(.ink)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.shade)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 40)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Formatting
    private func dueDateLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "yyyy.MM.dd(EEE)"
        return "⌛ " + f.string(from: date) + " 까지"
    }

    private func reminderLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "yyyy.MM.dd(EEE) a h:mm"
        return f.string(from: date)
    }

    // MARK: - Keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
        )
    }
}
