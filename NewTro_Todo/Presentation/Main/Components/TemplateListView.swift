import SwiftUI

struct TemplateListView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss

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

                    Text("템플릿 목록")
                        .font(.galBold16())
                        .foregroundColor(.ink)

                    Spacer()

                    NavigationLink(destination: TemplateFormView(viewModel: viewModel, editingTemplate: nil)) {
                        Text("+ 추가")
                            .font(.pressStart9())
                            .foregroundColor(.ink)
                            .padding(.horizontal, 8)
                            .frame(height: 30)
                            .background(Color.peach)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                            .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                Rectangle().fill(Color.ink.opacity(0.12)).frame(height: 1)

                // ── 목록 ──────────────────────────────────────────────
                if viewModel.templates.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.templates) { template in
                                templateRow(template)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { viewModel.loadTemplates() }
    }

    // MARK: - Row

    private func templateRow(_ template: TemplateEntity) -> some View {
        HStack(spacing: 0) {
            // 중요도 컬러 스트립
            Rectangle()
                .fill(importanceColor(template.importance))
                .frame(width: 6)

            // 내용
            HStack(spacing: 6) {
                if !template.emoji.isEmpty {
                    Text(template.emoji).font(.system(size: 14))
                }
                Text(template.text.isEmpty ? "..." : template.text)
                    .font(.galBold14())
                    .foregroundColor(.ink)
                    .lineLimit(1)
                Spacer(minLength: 4)

                // 편집 버튼
                NavigationLink(destination: TemplateFormView(viewModel: viewModel, editingTemplate: template)) {
                    Text("✎")
                        .font(.pressStart9())
                        .foregroundColor(.shade)
                        .frame(width: 28, height: 28)
                        .background(Color.cream)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.applyTemplate(template)
            dismiss()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("★")
                .font(.pressStart34())
                .foregroundColor(.shade.opacity(0.3))
            Text("저장된 템플릿이 없어요")
                .font(.galBold14())
                .foregroundColor(.shade.opacity(0.6))
            Text("+ 추가 버튼으로 만들어보세요")
                .font(.pressStart9())
                .foregroundColor(.shade.opacity(0.4))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func importanceColor(_ imp: Importance) -> Color {
        switch imp {
        case .high:   return .pixelRed
        case .medium: return .sun
        case .none:   return .grass
        }
    }
}
