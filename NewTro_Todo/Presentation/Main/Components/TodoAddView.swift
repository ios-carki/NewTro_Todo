import SwiftUI

struct TodoAddView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss

    // nil이면 신규 추가, non-nil이면 수정 모드
    var editingTodo: TodoEntity? = nil

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

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.panel.ignoresSafeArea()

            VStack(spacing: 0) {
                handleBar.padding(.top, 12)

                Text(isEditMode ? "할 일 수정" : "새 할 일")
                    .font(.galBold16())
                    .foregroundColor(.ink)
                    .padding(.top, 16)
                    .padding(.bottom, 14)

                // Text field
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
                .padding(.horizontal, 16)

                // Emoji picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        emojiChip("", label: "없음")
                        ForEach(emojis, id: \.self) { emoji in
                            emojiChip(emoji)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 12)

                // Importance
                HStack(spacing: 0) {
                    importanceChip(.none,   label: "낮음")
                    importanceChip(.medium, label: "보통")
                    importanceChip(.high,   label: "높음")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // Due time toggle + picker
                VStack(spacing: 8) {
                    HStack {
                        Text("알림 시간")
                            .font(.pressStart9())
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
                .padding(.top, 12)

                // Buttons
                HStack(spacing: 10) {
                    Button { dismiss() } label: {
                        Text("취소")
                            .font(.galBold14())
                            .foregroundColor(.shade)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(Color.panel)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    }

                    Button { save() } label: {
                        HStack(spacing: 4) {
                            Text(isEditMode ? "✎" : "★")
                                .font(.pressStart12())
                            Text(isEditMode ? "수정" : "저장")
                                .font(.galBold14())
                        }
                        .foregroundColor(.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(text.trimmingCharacters(in: .whitespaces).isEmpty ? Color.shade.opacity(0.2) : Color.peach)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
                    }
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .onAppear { populateIfEditing() }
    }

    // MARK: - Helpers

    private var handleBar: some View {
        Capsule()
            .fill(Color.ink.opacity(0.25))
            .frame(width: 40, height: 4)
    }

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
                        .font(.pressStart7())
                        .foregroundColor(isSelected ? .cream : .ink)
                } else {
                    Text(emoji).font(.system(size: 18))
                }
            }
            .frame(width: 38, height: 38)
            .background(isSelected ? Color.ink : Color.cream)
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
                .font(.pressStart9())
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
