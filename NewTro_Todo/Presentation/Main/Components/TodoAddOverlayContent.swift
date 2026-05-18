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
    // 박스 제거 — TextField 영역 하단에만 2pt 밑줄. 우측 [템플릿] 버튼은 expanded 에서만 노출.
    // 밑줄은 TextField 영역 한정 — 템플릿 버튼 아래로는 이어지지 않음.
    private var textInputRow: some View {
        HStack(spacing: 10) {
            VStack(spacing: 0) {
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
                .frame(height: 40)
                Rectangle()
                    .fill(Color.ink)
                    .frame(height: 2)
            }

            if isExpanded {
                templateInlineButton
            }
        }
    }

    // expanded 에서 TextField 우측에 인라인 노출. 저장된 템플릿 선택 화면을 시트로 띄움.
    private var templateInlineButton: some View {
        Button {
            hideKeyboard()
            onShowTemplates()
        } label: {
            Text("템플릿")
                .font(.galBold13())
                .foregroundColor(.ink)
                .padding(.horizontal, 10)
                .frame(height: 32)
                .background(Color.cream)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        }
        .buttonStyle(.plain)
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
    // 섹션 헤더 라벨 제거. 각 row 의 첫 항목으로 라벨이 inline 포함.
    // 순서: 색 → 기한 → 중요도 → 알림. (템플릿은 TextField 우측 인라인 버튼으로 이동)
    private var expandedSections: some View {
        VStack(spacing: 14) {
            colorSection
                .padding(.top, 18)
            dueSection
            importanceSection
            reminderSection
                .padding(.bottom, 24)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - 기한 (Expanded)
    // 인라인 row: [모래시계] [라벨 또는 설정된 날짜] [Spacer] [Toggle]
    //  - OFF: "기한 없음"
    //  - ON:  "yyyy.MM.dd(EEE) 까지" (galBold16 — 라벨보다 살짝 큰 시각 강조)
    private var dueSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                PixelArtView(
                    grid: PixelArtAssets.dotHourglassGrid,
                    palette: PixelArtAssets.dotHourglassPalette,
                    scale: 2
                )
                if formState.hasDueDate {
                    Text(dueDateInlineLabel(formState.dueDate))
                        .font(.galBold16())
                        .foregroundColor(.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                } else {
                    Text("기한 없음")
                        .font(.galBold14())
                        .foregroundColor(.shade)
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
            .frame(minHeight: 36)

            if formState.hasDueDate {
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

    private func dueDateInlineLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "yyyy.MM.dd(EEE)"
        return f.string(from: date) + " 까지"
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
    // 인라인 row: [중요도] [Spacer] [낮음] [보통] [높음]
    private var importanceSection: some View {
        HStack(spacing: 6) {
            Text("중요도")
                .font(.galBold14())
                .foregroundColor(.ink)
            Spacer()
            importanceChip(.none,   label: "낮음")
            importanceChip(.medium, label: "보통")
            importanceChip(.high,   label: "높음")
        }
        .frame(minHeight: 36)
    }

    private func importanceChip(_ imp: Importance, label: LocalizedStringKey) -> some View {
        let isSelected = formState.importance == imp
        // 선택 시: 연한 배경 + 진한 텍스트. 톤다운된 파스텔 + Dk 텍스트 페어링.
        let chipBg: Color = switch imp {
        case .none:   .grassLt
        case .medium: .sunLt
        case .high:   .redLt
        }
        let selectedTextColor: Color = switch imp {
        case .none:   .grassDk
        case .medium: .sunDk
        case .high:   .redDk
        }
        return Button {
            hideKeyboard()
            formState.importance = imp
        } label: {
            Text(label)
                .font(.galBold13())
                .foregroundColor(isSelected ? selectedTextColor : .ink)
                .padding(.horizontal, 10)
                .frame(height: 32)
                .background(isSelected ? chipBg : Color.cream)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    // MARK: - 색
    // 메모(QuickNote)와 동일한 6색 팔레트 공유. 행 자체 배경에 적용되며 중요도 strip 은 그대로 유지.
    // 인라인 row: [색] [스와치 6개 — 가용폭 균등 분할]
    private var colorSection: some View {
        HStack(spacing: 8) {
            Text("색")
                .font(.galBold14())
                .foregroundColor(.ink)

            HStack(spacing: 6) {
                ForEach(MemoColorPalette.all, id: \.name) { item in
                    Button {
                        hideKeyboard()
                        formState.colorName = item.name
                    } label: {
                        let isSelected = formState.colorName == item.name
                        item.color
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                            .overlay(
                                Rectangle().stroke(
                                    isSelected ? Color.ink : Color.ink.opacity(0.3),
                                    lineWidth: isSelected ? 2.5 : 1.5
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(minHeight: 36)
    }

    // MARK: - 알림
    // 토글 없음 — row 전체를 누르면 picker 가 열리고, picker 의 "선택"/"끄기" 로 hasReminder 결정.
    //  OFF: [종] 알림
    //  ON:  [종] 알림 [Spacer] 2026.05.18(일) 오후 1:10 [chevron]
    private var reminderSection: some View {
        Button {
            hideKeyboard()
            if !formState.hasReminder, formState.reminderDate < Date() {
                formState.reminderDate = ReminderDatePickerView.defaultReminderDate()
            }
            onShowReminder()
        } label: {
            HStack(spacing: 8) {
                PixelArtView(
                    grid: PixelArtAssets.dotBellGrid,
                    palette: PixelArtAssets.dotBellPalette,
                    scale: 2
                )
                Text("알림")
                    .font(.galBold14())
                    .foregroundColor(.ink)
                Spacer()
                if formState.hasReminder {
                    Text(reminderLabel(formState.reminderDate))
                        .font(.galBold13())
                        .foregroundColor(.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    PixelArtView(
                        grid: PixelArtAssets.dotChevronRightGrid,
                        palette: PixelArtAssets.dotChevronRightPalette,
                        scale: 2
                    )
                }
            }
            .frame(minHeight: 36)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Formatting
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
