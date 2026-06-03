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
    var onDelete: () -> Void

    @State private var dragOffset: CGFloat = 0
    // 편집 모드 하단 삭제 버튼 → 즉시 삭제 X, 커스텀 확인 팝업 띄움.
    @State private var showDeleteConfirm: Bool = false
    // AutoFocusTextField 가 측정해서 보고한 콘텐츠 height. SwiftUI .frame(height:) 로 직접 적용
    //   → SwiftUI 가 자식의 fit 사이즈를 모르고 maxHeight 까지 stretch 시키는 회귀 차단.
    //   초기값은 1줄 분량(singleLineHeight) — 최초 보고 들어오기 전 시각 안정.
    @State private var inputHeight: CGFloat = TodoAddOverlayContent.singleLineHeight

    // 1줄 분량 높이 — compact 고정 + expanded 빈 상태 초기값. textContainerInset top 6 + bottom 14.
    static let singleLineHeight: CGFloat = {
        let font = UIFont.boldFont(size: 14)
        return font.lineHeight + 20
    }()

    var body: some View {
        ZStack {
            mainPanel

            if showDeleteConfirm {
                deleteConfirmOverlay
                    .transition(.opacity)
            }
        }
    }

    private var mainPanel: some View {
        VStack(spacing: 0) {
            // 위치 0: 헤더 — expanded 한정. compact 는 헤더 없이 textInputRow 부터 시작.
            //   (compact dragHandle 제거. swipe-down dismiss 는 mainPanel 전역 gesture 로 유지)
            if isExpanded {
                topBar
            }

            // 위치 1: TextField — compact/expanded 양쪽에서 동일 위치 → identity 보존 → keyboard 유지.
            textInputRow
                .padding(.horizontal, 16)
                .padding(.top, isExpanded ? 4 : 14)
                .padding(.bottom, isExpanded ? 0 : 10)

            // 위치 2: 본문 — compact: 짧은 듀로우+세부버튼 / expanded: 스크롤 섹션.
            if isExpanded {
                ScrollView(showsIndicators: false) {
                    expandedSections
                }
                .scrollDismissesKeyboard(.interactively)

                // 위치 3: 편집 모드 한정 — 화면 최하단에 고정된 삭제 버튼.
                // ScrollView 바깥에 두어 스크롤과 무관하게 항상 바닥에 노출.
                if formState.isEditMode {
                    deleteButton
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                }
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
        // expanded 한정 — 키보드 safe area 무시. ScrollView 와 하단 삭제 버튼이 키보드와 함께
        // 위로 끌려 올라가지 않도록 고정. compact 에선 빈 Edge.Set 으로 기존 키보드 회피 동작 유지
        //   (compact 패널은 키보드 위로 올라와야 TextField 가 가려지지 않음).
        .ignoresSafeArea(.keyboard, edges: isExpanded ? .bottom : [])
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
    //
    // 동작:
    //  - compact: onMultilineDetected → 1줄 분량을 넘기는 순간 expanded 로 morph.
    //    높이는 항상 1줄로 고정 (.frame 에서 singleLineHeight 분기).
    //  - expanded: onHeightChange 로 콘텐츠 height 받아 자유 grow/shrink (상한 캡 없음).
    //    캡 + isScrollEnabled=false 조합은 캡 도달 직전 wrap 끊김 회귀가 있어 캡 제거.
    //  - charLimit 100 → 한 todo 의 텍스트 상한. Galmuri 14pt 기준 5줄 분량 ≈ 자연 가드.
    private var textInputRow: some View {
        HStack(alignment: .top, spacing: 10) {
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
                        // 긴 화면(expanded): 키보드만 내림. 저장은 우측 상단 체크 버튼으로.
                        // compact: 기존 동작 — 비어있으면 토스트, 아니면 저장.
                        if isExpanded {
                            return true
                        }
                        if formState.isEmpty {
                            onEmptyAttempt()
                            return false
                        }
                        onSave()
                        return true
                    },
                    onMultilineDetected: isExpanded ? nil : {
                        // wrap 발생 → 같은 turn 안에서 expanded 로 morph.
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isExpanded = true
                        }
                    },
                    // 5줄 분량 상한. Galmuri 14pt 기준 한 줄 한글 ~20자 → 5줄 ≈ 100자.
                    // 영문은 같은 100자에 더 짧은 줄로 들어가도 5줄을 크게 안 넘김.
                    charLimit: 100,
                    onHeightChange: { measured in
                        // UITextView 가 측정한 콘텐츠 height. compact 는 1줄 고정 (.frame 에서 분기).
                        // expanded 는 singleLineHeight 이상으로만 clamp (상한 캡 없음).
                        //   캡 두면 scroll OFF 와 조합에서 캡 도달 시 wrap 끊김 버그 회귀 →
                        //   charLimit 100 자가 사실상 5줄 안에서 끝나도록 자연 가드.
                        inputHeight = max(measured, Self.singleLineHeight)
                    }
                )
                // SwiftUI 가 UITextView 의 fit 사이즈를 안정적으로 인지 못 하는 케이스가 있어,
                //   onHeightChange 로 명시 보고된 inputHeight 로 .frame(height:) 직접 적용.
                // compact: 항상 1줄 고정 — wrap 발생 시 onMultilineDetected 가 expanded 로 morph.
                // expanded: 콘텐츠 줄 수 따라 grow/shrink. charLimit 100 자가 자연 가드 (≈ 5줄).
                .frame(
                    height: isExpanded ? inputHeight : Self.singleLineHeight,
                    alignment: .topLeading
                )
                .clipped()
                Rectangle()
                    .fill(Color.ink.opacity(0.3))
                    .frame(height: 1.5)
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
    // expanded 의 dueSection 과 동일 디자인 (섹션 박스 포함) — 깃발 픽셀 + inline 날짜 + 토글,
    // ON 일 때 칩 row 노출. "직접 설정" 칩은 compact 에서 누르면 expanded 로 강제 전환되며
    // wheel 도 함께 열림 (chip 액션 분기에서 처리). compact 에선 dueCustomOpen 이 항상 false 라
    // wheel 블록은 렌더되지 않음.
    private var compactDueRow: some View {
        sectionContainer { dueSection }
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
    // 각 섹션은 panel 보다 살짝 진한 ink 5% 오버레이 박스로 감싸 시각 분리.
    // 삭제 버튼은 ScrollView 바깥(화면 최하단)으로 이동 — body 의 위치 3 참조.
    private var expandedSections: some View {
        VStack(spacing: 10) {
            sectionContainer { colorSection }
                .padding(.top, 14)
            sectionContainer { dueSection }
            sectionContainer { importanceSection }
            sectionContainer { reminderSection }

            Color.clear.frame(height: 24)
        }
        .padding(.horizontal, 16)
    }

    private var deleteButton: some View {
        Button {
            hideKeyboard()
            withAnimation(.easeInOut(duration: 0.18)) {
                showDeleteConfirm = true
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.pixelRed)
                    .frame(width: 56, height: 56)
                    .overlay(Circle().stroke(Color.ink, lineWidth: 2))

                PixelArtView(
                    grid: PixelArtAssets.dotTrashGrid,
                    palette: PixelArtAssets.dotTrashPalette,
                    scale: 2.5
                )
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("editDelete")
    }

    // MARK: - Delete Confirm Overlay
    // dim 배경 + 픽셀톤 패널 카드. 우측 "삭제"는 pixelRed, 좌측 "취소"는 cream.
    // dim tap 시 dismiss. 시스템 .alert 대신 디자인 시스템에 맞춘 커스텀 팝업.
    private var deleteConfirmOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        showDeleteConfirm = false
                    }
                }

            VStack(spacing: 10) {
                Text("Todo를 삭제합니다")
                    .font(.galBold17())
                    .foregroundColor(.ink)
                    .multilineTextAlignment(.center)

                Text("삭제된 Todo는 복구가 불가능합니다")
                    .font(.galBold13())
                    .foregroundColor(.shade)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 6)

                HStack(spacing: 10) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            showDeleteConfirm = false
                        }
                    } label: {
                        Text("취소")
                            .font(.galBold14())
                            .foregroundColor(.ink)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(Color.cream)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("deleteCancel")

                    Button {
                        showDeleteConfirm = false
                        onDelete()
                    } label: {
                        Text("삭제")
                            .font(.galBold14())
                            .foregroundColor(.cream)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(Color.pixelRed)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("deleteConfirm")
                }
            }
            .padding(20)
            .background(Color.panel)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            .padding(.horizontal, 40)
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func sectionContainer<V: View>(@ViewBuilder _ content: () -> V) -> some View {
        content()
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.ink.opacity(0.05))
    }

    // MARK: - 기한 (Expanded)
    // 인라인 row: [모래시계] [라벨 또는 설정된 날짜] [Spacer] [Toggle]
    //  - OFF: "기한 없음"
    //  - ON:  "yyyy.MM.dd(EEE) 까지" (galBold16 — 라벨보다 살짝 큰 시각 강조)
    private var dueSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                PixelArtView(
                    grid: PixelArtAssets.dotFlagGrid,
                    palette: PixelArtAssets.dotFlagPalette,
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
                    // compact 에선 사용자가 텍스트 입력 중일 가능성이 커 키보드 유지.
                    if isExpanded { hideKeyboard() }
                    withAnimation(.easeInOut(duration: 0.25)) {
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
                    .padding(.top, 6)
                    // 칩 라인에서 펼쳐지는 느낌 — top 앵커로 scale up + fade in.
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.85, anchor: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }

            dueTargetHelperRow
        }
    }

    // 기한 라벨이 실제 등록 날짜로 작용함을 안내. hasDueDate 여부에 따라 dueDate 또는 selectedDate 기준.
    private var dueTargetHelperRow: some View {
        let target = formState.hasDueDate ? formState.dueDate : viewModel.selectedDate
        return HStack(spacing: 6) {
            PixelArtView(
                grid: PixelArtAssets.dotInfoGrid,
                palette: PixelArtAssets.dotInfoPalette,
                scale: 2
            )
            Text("%@ 에 Todo가 추가됩니다".localized(with: helperTargetDateLabel(target)))
                .font(.galBold11())
                .foregroundColor(.shade)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
        }
        .padding(.top, 2)
    }

    private func helperTargetDateLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "yyyy-MM-dd (E)"
        return f.string(from: date)
    }

    private func dueDateInlineLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.setLocalizedDateFormatFromTemplate("yMMMdEEE")
        // "<날짜> 까지" 의 접미사도 언어별로 위치가 달라 포맷 키로 처리.
        return "%@ 까지".localized(with: f.string(from: date))
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
                // compact 에서 누르면 long 화면으로 전환하면서 wheel 열림.
                // expanded 에선 toggle 동작 유지 — 재탭으로 닫기 가능.
                if isExpanded {
                    formState.dueCustomOpen.toggle()
                } else {
                    formState.dueCustomOpen = true
                    isExpanded = true
                }
            }
        }
    }

    private func dueChipButton(_ title: LocalizedStringKey, chip: TodoFormState.DueChip, onTap: @escaping () -> Void) -> some View {
        let isActive = (formState.dueChip == chip)
        return Button {
            // compact 에선 텍스트 입력 흐름을 끊지 않도록 키보드 유지.
            // 직접 설정 칩이 compact → expand 전이를 일으켜도, isExpanded 가 아직 false 인 시점에
            // 검사하므로 hideKeyboard 는 호출되지 않음.
            if isExpanded { hideKeyboard() }
            withAnimation(.easeInOut(duration: 0.25)) {
                onTap()
            }
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
    // 인라인 row: [막대] [중요도] [Spacer] [낮음] [보통] [높음]
    private var importanceSection: some View {
        HStack(spacing: 8) {
            PixelArtView(
                grid: PixelArtAssets.dotBarsGrid,
                palette: PixelArtAssets.dotBarsPalette,
                scale: 2
            )
            Text("중요도")
                .font(.galBold14())
                .foregroundColor(.ink)
            Spacer()
            HStack(spacing: 6) {
                importanceChip(.none,   label: "낮음")
                importanceChip(.medium, label: "보통")
                importanceChip(.high,   label: "높음")
            }
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

    // MARK: - 색상
    // 메모(QuickNote)와 동일한 6색 팔레트 공유. 행 자체 배경에 적용되며 중요도 strip 은 그대로 유지.
    // 인라인 row: [팔렛] [색상] [스와치 6개 — 가용폭 균등 분할]
    private var colorSection: some View {
        HStack(spacing: 8) {
            PixelArtView(
                grid: PixelArtAssets.dotPaletteGrid,
                palette: PixelArtAssets.dotPalettePalette,
                scale: 2
            )
            Text("색상")
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
