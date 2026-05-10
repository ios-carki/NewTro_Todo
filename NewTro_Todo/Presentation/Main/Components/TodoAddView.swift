import SwiftUI

struct TodoAddView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    var editingTodo: TodoEntity? = nil
    @Binding var isExpanded: Bool

    @State private var text: String = ""
    @State private var selectedEmoji: String = ""
    @State private var importance: Importance = .none
    @State private var hasDueTime: Bool = false
    @State private var dueTime: Date = {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 9; comps.minute = 0
        return Calendar.current.date(from: comps) ?? Date()
    }()

    private let emojis = ["🔥", "💪", "📚", "🏃", "💡", "🎯", "❤️", "🍀", "🎵", "🌙", "✏️", "☕"]
    private var isEditMode: Bool { editingTodo != nil }
    private var isEmpty: Bool { text.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ZStack {
            Color.panel.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── 타이틀 (고정)
                Text(isEditMode ? "할 일 수정" : "새 할 일")
                    .font(.galBold16())
                    .foregroundColor(.ink)
                    .padding(.top, 16)
                    .padding(.bottom, 14)

                // ── 스크롤 영역
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // 텍스트 입력
                        textInputSection
                            .padding(.horizontal, 16)

                        // 템플릿 (large 전용)
                        if isExpanded {
                            sectionLabel("템플릿")
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                                    removal: .opacity
                                ))
                            NavigationLink(destination: TemplateListView(viewModel: viewModel)) {
                                HStack {
                                    Text("저장된 템플릿")
                                        .font(.galBold14())
                                        .foregroundColor(.ink)
                                    Spacer()
                                    Text("목록 보기 >")
                                        .font(.pressStart7())
                                        .foregroundColor(.shade)
                                }
                                .padding(.horizontal, 14)
                                .frame(height: 44)
                                .background(Color.cream)
                                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                            }
                            .padding(.horizontal, 16)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity
                            ))
                        }

                        // 이모지
                        sectionLabel("이모지 선택")
                        emojiSection

                        // 중요도
                        sectionLabel("중요도")
                        importanceSection
                            .padding(.horizontal, 16)

                        // 알림 (large 전용)
                        if isExpanded {
                            notificationSection
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                                    removal: .opacity
                                ))
                        }

                        Spacer().frame(height: 8)
                    }
                    .animation(.easeInOut(duration: 0.25), value: isExpanded)
                }

                // ── 구분선
                Rectangle()
                    .fill(Color.ink.opacity(0.12))
                    .frame(height: 1)

                // ── 버튼 (고정)
                HStack(spacing: 10) {
                    Button { dismiss() } label: {
                        Text("취소")
                            .font(.galBold14())
                            .foregroundColor(.shade)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(Color.cream)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    }

                    Button { save() } label: {
                        HStack(spacing: 4) {
                            Text(isEditMode ? "✎" : "★")
                                .font(.pressStart12())
                            Text(isEditMode ? "수정" : "저장")
                                .font(.galBold14())
                        }
                        .foregroundColor(isEmpty ? Color.shade : Color.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(isEmpty ? Color.shade.opacity(0.1) : Color.peach)
                        .overlay(Rectangle().stroke(isEmpty ? Color.shade.opacity(0.4) : Color.ink, lineWidth: 2))
                        .background(Rectangle().fill(isEmpty ? Color.clear : Color.ink).offset(x: 2, y: 2))
                    }
                    .disabled(isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }

            // 숨겨진 compact 높이 측정 뷰 — layout에 영향 없이 자연 높이만 보고
            compactContentSizer
                .frame(width: 0, height: 0)
                .clipped()
        }
        .onAppear { populateIfEditing() }
        .onChange(of: viewModel.pendingTemplate) { template in
            guard let t = template else { return }
            text = t.text
            selectedEmoji = t.emoji
            importance = t.importance
            viewModel.pendingTemplate = nil
        }
    }

    // MARK: - Compact Content Sizer
    // 실제 compact 콘텐츠와 동일한 구조를 unconstrained 높이로 렌더링해 자연 높이를 측정.
    // sectionLabel()을 직접 호출하므로 폰트/패딩 변경 시 자동 반영.
    private var compactContentSizer: some View {
        VStack(spacing: 0) {
            // Header (타이틀 영역)
            Text(isEditMode ? "할 일 수정" : "새 할 일")
                .font(.galBold16())
                .padding(.top, 16)
                .padding(.bottom, 14)

            // 텍스트 입력 (compact: 고정 46pt)
            Color.clear
                .frame(height: 46)
                .padding(.horizontal, 16)

            // 이모지 섹션 라벨 + 칩 행
            sectionLabel("이모지 선택")
            Color.clear.frame(height: 46)   // 칩 높이

            // 중요도 섹션 라벨 + 칩
            sectionLabel("중요도")
            Color.clear
                .frame(height: 36)
                .padding(.horizontal, 16)

            // 하단 여백
            Color.clear.frame(height: 8)

            // 구분선
            Color.clear.frame(height: 1)

            // 버튼 영역 (padding.top 12 + height 46 + padding.bottom 24 = 82)
            Color.clear.frame(height: 82)
        }
        .fixedSize(horizontal: false, vertical: true)
        .hidden()
        .background(
            GeometryReader { geo in
                Color.clear.preference(key: TodoAddScrollHeightKey.self, value: geo.size.height)
            }
        )
    }

    // MARK: - Section Label

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

    // MARK: - Text Input
    // ZStack 컨테이너의 frame 높이가 애니메이션되고, 내부 컨텐츠는 opacity 전환.

    private var textInputSection: some View {
        ZStack(alignment: isExpanded ? .topLeading : .leading) {
            if isExpanded {
                ZStack(alignment: .topLeading) {
                    if !selectedEmoji.isEmpty {
                        Text(selectedEmoji)
                            .font(.system(size: 18))
                            .padding(.top, 10)
                            .padding(.leading, 10)
                    }
                    TextEditor(text: $text)
                        .font(.galBold14())
                        .foregroundColor(.ink)
                        .background(Color.clear)
                        .padding(.leading, selectedEmoji.isEmpty ? 6 : 28)
                        .padding(.vertical, 4)

                    if text.isEmpty {
                        Text("할 일을 입력하세요")
                            .font(.galBold14())
                            .foregroundColor(.ink.opacity(0.4))
                            .padding(.top, 12)
                            .padding(.leading, selectedEmoji.isEmpty ? 12 : 34)
                            .allowsHitTesting(false)
                    }
                }
                .transition(.opacity)
            } else {
                ZStack(alignment: .leading) {
                    HStack(spacing: 8) {
                        if !selectedEmoji.isEmpty {
                            Text(selectedEmoji).font(.system(size: 18))
                        }
                        // 시스템 placeholder 색을 직접 바꿀 수 없어 빈 prompt + custom overlay
                        TextField("", text: $text)
                            .font(.galBold14())
                            .foregroundColor(.ink)
                            .accessibilityIdentifier("todoTextField")
                    }
                    .padding(.horizontal, 14)

                    if text.isEmpty {
                        Text("할 일을 입력하세요")
                            .font(.galBold14())
                            .foregroundColor(.ink.opacity(0.4))
                            .padding(.leading, selectedEmoji.isEmpty ? 14 : 40)
                            .allowsHitTesting(false)
                    }
                }
                .transition(.opacity)
            }
        }
        .frame(minHeight: isExpanded ? 80 : 46, maxHeight: isExpanded ? 140 : 46)
        .background(Color.cream)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .clipped()
    }

    // MARK: - Emoji Section

    @ViewBuilder
    private var emojiSection: some View {
        if isExpanded {
            let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
            LazyVGrid(columns: gridColumns, spacing: 8) {
                emojiChip("", label: "없음")
                ForEach(emojis, id: \.self) { emojiChip($0) }
            }
            .padding(.horizontal, 16)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.97, anchor: .top)),
                removal: .opacity.combined(with: .scale(scale: 0.97, anchor: .top))
            ))
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    emojiChip("", label: "없음")
                    ForEach(emojis, id: \.self) { emojiChip($0) }
                }
                .padding(.horizontal, 16)
            }
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.97, anchor: .top)),
                removal: .opacity.combined(with: .scale(scale: 0.97, anchor: .top))
            ))
        }
    }

    // MARK: - Importance Section

    private var importanceSection: some View {
        HStack(spacing: 0) {
            importanceChip(.none,   label: "낮음")
            importanceChip(.medium, label: "보통")
            importanceChip(.high,   label: "높음")
        }
    }

    // MARK: - Notification Section

    private var notificationSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("알림 시간")
                    .font(.galCondensed16())
                    .foregroundColor(.shade)
                Spacer()
                Toggle("", isOn: $hasDueTime)
                    .labelsHidden()
                    .tint(.grass)
            }
            .padding(.horizontal, 16)

            if hasDueTime {
                DatePicker("", selection: $dueTime, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(height: 100)
                    .clipped()
            }
        }
        .padding(.top, 14)
    }

    // MARK: - Helpers

    private func populateIfEditing() {
        guard let todo = editingTodo else { return }
        text = todo.text
        selectedEmoji = todo.emoji
        importance = todo.importance
        if let dt = todo.dueTime {
            hasDueTime = true
            dueTime = dt
        }
    }

    private func emojiChip(_ emoji: String, label: LocalizedStringKey? = nil) -> some View {
        let isSelected = selectedEmoji == emoji
        return Button { selectedEmoji = emoji } label: {
            Group {
                if emoji.isEmpty {
                    Text(label ?? "없음")
                        .font(.galBold14())
                        .foregroundColor(isSelected ? .ink : .shade)
                } else {
                    Text(emoji).font(.system(size: 20))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(width: 46, height: 46)
            .background(isSelected ? Color.peach : Color.cream)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        }
    }

    private func importanceChip(_ imp: Importance, label: LocalizedStringKey) -> some View {
        let isSelected = importance == imp
        let chipColor: Color = switch imp {
        case .none:   .grass
        case .medium: .sun
        case .high:   .pixelRed
        }
        return Button { importance = imp } label: {
            Text(label)
                .font(.galCondensed16())
                .foregroundColor(isSelected ? .cream : .ink)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(isSelected ? chipColor : Color.cream)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        }
    }

    private func save() {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let resolvedDueTime: Date?
        if hasDueTime {
            let dayComps = Calendar.current.dateComponents([.year, .month, .day], from: viewModel.selectedDate)
            let timeComps = Calendar.current.dateComponents([.hour, .minute], from: dueTime)
            var merged = DateComponents()
            merged.year = dayComps.year; merged.month = dayComps.month; merged.day = dayComps.day
            merged.hour = timeComps.hour; merged.minute = timeComps.minute
            resolvedDueTime = Calendar.current.date(from: merged)
        } else {
            resolvedDueTime = nil
        }

        if let todo = editingTodo {
            viewModel.editTodo(id: todo.id, text: trimmed, emoji: selectedEmoji, importance: importance, dueTime: resolvedDueTime)
        } else {
            viewModel.addTodo(text: trimmed, emoji: selectedEmoji, importance: importance, dueTime: resolvedDueTime)
        }
        dismiss()
    }
}

// MARK: - PreferenceKey

struct TodoAddScrollHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview { @MainActor in
    let di = DIContainer()
    return TodoAddView(viewModel: di.makeMainViewModel(), isExpanded: .constant(true))
}
