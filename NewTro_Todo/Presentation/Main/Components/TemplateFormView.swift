import SwiftUI

struct TemplateFormView: View {
    @ObservedObject var viewModel: MainViewModel
    var editingTemplate: TemplateEntity?
    @Environment(\.dismiss) private var dismiss

    @State private var text: String = ""
    @State private var selectedEmoji: String = ""
    @State private var importance: Importance = .none

    private let emojis = ["🔥", "💪", "📚", "🏃", "💡", "🎯", "❤️", "🍀", "🎵", "🌙", "✏️", "☕"]
    private var isEditMode: Bool { editingTemplate != nil }
    private var isEmpty: Bool { text.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ZStack {
            Color.panel.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── 헤더 ──────────────────────────────────────────────
                HStack {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Text("◀")
                                .font(.pressStart9())
                            Text("뒤로")
                                .font(.galBold14())
                        }
                        .foregroundColor(.ink)
                    }

                    Spacer()

                    Text(isEditMode ? "템플릿 편집" : "새 템플릿")
                        .font(.galBold16())
                        .foregroundColor(.ink)

                    Spacer()

                    // 정렬용 투명 공간
                    Text("뒤로").font(.galBold14()).opacity(0)
                        .overlay(Text("◀").font(.pressStart9()).opacity(0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                Rectangle().fill(Color.ink.opacity(0.12)).frame(height: 1)

                // ── 폼 영역 ───────────────────────────────────────────
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // 텍스트
                        HStack(spacing: 8) {
                            if !selectedEmoji.isEmpty {
                                Text(selectedEmoji).font(.system(size: 18))
                            }
                            TextField("템플릿 이름을 입력하세요", text: $text)
                                .font(.galBold14())
                                .foregroundColor(.ink)
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 46)
                        .background(Color.cream)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                        .padding(.horizontal, 16)

                        // 이모지
                        sectionLabel("이모지 선택")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                emojiChip("", label: "없음")
                                ForEach(emojis, id: \.self) { emojiChip($0) }
                            }
                            .padding(.horizontal, 16)
                        }

                        // 중요도
                        sectionLabel("중요도")
                        HStack(spacing: 0) {
                            importanceChip(.none,   label: "낮음")
                            importanceChip(.medium, label: "보통")
                            importanceChip(.high,   label: "높음")
                        }
                        .padding(.horizontal, 16)

                        Spacer().frame(height: 8)
                    }
                }

                // ── 버튼 (고정) ───────────────────────────────────────
                Rectangle().fill(Color.ink.opacity(0.12)).frame(height: 1)

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
                            Text("★").font(.pressStart12())
                            Text(isEditMode ? "수정" : "저장").font(.galBold14())
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
        .navigationBarHidden(true)
        .onAppear { populate() }
    }

    // MARK: - Section Label

    private func sectionLabel(_ title: LocalizedStringKey) -> some View {
        HStack {
            Text(title).font(.pressStart9()).foregroundColor(.shade)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 6)
    }

    // MARK: - Chips

    private func emojiChip(_ emoji: String, label: LocalizedStringKey? = nil) -> some View {
        let isSelected = selectedEmoji == emoji
        return Button { selectedEmoji = emoji } label: {
            Group {
                if emoji.isEmpty {
                    Text(label ?? "없음").font(.galBold14())
                        .foregroundColor(isSelected ? .ink : .shade)
                } else {
                    Text(emoji).font(.system(size: 20))
                }
            }
            .frame(width: 52, height: 44)
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
                .font(.pressStart9())
                .foregroundColor(isSelected ? .cream : .ink)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(isSelected ? chipColor : Color.cream)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        }
    }

    // MARK: - Logic

    private func populate() {
        guard let t = editingTemplate else { return }
        text = t.text
        selectedEmoji = t.emoji
        importance = t.importance
    }

    private func save() {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        if let t = editingTemplate {
            viewModel.updateTemplate(id: t.id, text: trimmed, emoji: selectedEmoji, importance: importance)
        } else {
            viewModel.saveTemplate(text: trimmed, emoji: selectedEmoji, importance: importance)
        }
        dismiss()
    }
}
