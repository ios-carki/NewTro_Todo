import SwiftUI

struct TodoAddView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    var editingTodo: TodoEntity? = nil
    @Binding var selectedDetent: PresentationDetent

    @State private var text: String = ""
    @State private var selectedEmoji: String = ""
    @State private var importance: Importance = .none
    @State private var hasDueTime: Bool = false
    @State private var dueTime: Date = {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 9; comps.minute = 0
        return Calendar.current.date(from: comps) ?? Date()
    }()

    private let emojis = ["⭐", "🔥", "💪", "📚", "🏃", "💡", "🎯", "❤️", "🍀", "🎵", "🌙", "✏️"]
    private var isEditMode: Bool { editingTodo != nil }
    private var isExpanded: Bool { selectedDetent == .large }
    private var isEmpty: Bool { text.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ZStack {
            Color.panel.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── 타이틀 (고정) ─────────────────────────────────────
                Text(isEditMode ? "할 일 수정" : "새 할 일")
                    .font(.galBold16())
                    .foregroundColor(.ink)
                    .padding(.top, 16)
                    .padding(.bottom, 14)

                // ── 스크롤 영역 ───────────────────────────────────────
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // 텍스트 입력
                        textInputSection
                            .padding(.horizontal, 16)

                        // 템플릿 (large 전용)
                        if isExpanded {
                            sectionLabel("템플릿")
                            NavigationLink(value: TemplateNavDest.templateList) {
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
                            .transition(.opacity)
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
                                .transition(.opacity)
                        }

                        Spacer().frame(height: 8)
                    }
                    .animation(.easeInOut(duration: 0.25), value: isExpanded)
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: TodoAddScrollHeightKey.self,
                                value: geo.size.height
                            )
                        }
                    )
                }

                // ── 구분선 ────────────────────────────────────────────
                Rectangle()
                    .fill(Color.ink.opacity(0.12))
                    .frame(height: 1)

                // ── 버튼 (고정) ───────────────────────────────────────
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
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
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

    // MARK: - Section Label

    private func sectionLabel(_ title: String) -> some View {
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

    @ViewBuilder
    private var textInputSection: some View {
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
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 80, maxHeight: 140)
                    .padding(.leading, selectedEmoji.isEmpty ? 6 : 28)
                    .padding(.vertical, 4)

                if text.isEmpty {
                    Text("할 일을 입력하세요")
                        .font(.galBold14())
                        .foregroundColor(.shade.opacity(0.5))
                        .padding(.top, 12)
                        .padding(.leading, selectedEmoji.isEmpty ? 12 : 34)
                        .allowsHitTesting(false)
                }
            }
            .background(Color.cream)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            .transition(.opacity)
        } else {
            HStack(spacing: 8) {
                if !selectedEmoji.isEmpty {
                    Text(selectedEmoji).font(.system(size: 18))
                }
                TextField("할 일을 입력하세요", text: $text)
                    .font(.galBold14())
                    .foregroundColor(.ink)
            }
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(Color.cream)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            .transition(.opacity)
        }
    }

    // MARK: - Emoji Section

    @ViewBuilder
    private var emojiSection: some View {
        if isExpanded {
            let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
            LazyVGrid(columns: gridColumns, spacing: 8) {
                emojiChip("", label: "없음")
                ForEach(emojis, id: \.self) { emoji in
                    emojiChip(emoji)
                }
            }
            .padding(.horizontal, 16)
            .transition(.opacity)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    emojiChip("", label: "없음")
                    ForEach(emojis, id: \.self) { emoji in
                        emojiChip(emoji)
                    }
                }
                .padding(.horizontal, 16)
            }
            .transition(.opacity)
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

    private func emojiChip(_ emoji: String, label: String? = nil) -> some View {
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

    private func importanceChip(_ imp: Importance, label: String) -> some View {
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


struct TodoAddScrollHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview { @MainActor in
    let di = DIContainer()
    return TodoAddView(viewModel: di.makeMainViewModel(), selectedDetent: .constant(.height(380)))
}
