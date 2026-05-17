import SwiftUI

struct TemplateFormView: View {
    @ObservedObject var viewModel: MainViewModel
    var editingTemplate: TemplateEntity?
    @Environment(\.dismiss) private var dismiss

    @State private var text: String = ""
    @State private var importance: Importance = .none

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
                        // SwiftUI TextField placeholder는 시스템 secondaryLabel(연한 회색) 고정이라
                        // cream 배경 위에서는 거의 보이지 않음. ZStack 오버레이로 직접 그려 색·폰트 제어.
                        ZStack(alignment: .leading) {
                            if text.isEmpty {
                                Text("새 템플릿으로 추가할 할 일을 작성해주세요")
                                    .font(.galBold14())
                                    .foregroundColor(.shade.opacity(0.55))
                                    .allowsHitTesting(false)
                            }
                            TextField("", text: $text)
                                .font(.galBold14())
                                .foregroundColor(.ink)
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 46)
                        .background(Color.cream)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                        .padding(.horizontal, 16)
                        .padding(.top, 18)

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
            Text(title).font(.galBold14()).foregroundColor(.shade)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Chips

    private func importanceChip(_ imp: Importance, label: LocalizedStringKey) -> some View {
        let isSelected = importance == imp
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
        return Button { importance = imp } label: {
            Text(label)
                .font(.galBold14())
                .foregroundColor(isSelected ? selectedTextColor : .ink)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(isSelected ? chipBg : Color.cream)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        }
    }

    // MARK: - Logic

    private func populate() {
        guard let t = editingTemplate else { return }
        text = t.text
        importance = t.importance
    }

    private func save() {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        if let t = editingTemplate {
            viewModel.updateTemplate(id: t.id, text: trimmed, importance: importance)
        } else {
            viewModel.saveTemplate(text: trimmed, importance: importance)
        }
        dismiss()
    }
}
