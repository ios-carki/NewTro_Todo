import SwiftUI

struct TemplateListView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.panel.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── 커스텀 grab handle ───────────────────────────────
                // 시스템 .presentationDragIndicator 는 NavigationStack 안에서 sheet 트랜지션 종료 후
                // 페이드인되는 케이스가 있어 (특히 첫 등장 시) 콘텐츠와 같이 즉시 보이는 커스텀 핸들 사용.
                Capsule()
                    .fill(Color.ink.opacity(0.25))
                    .frame(width: 36, height: 5)
                    .padding(.top, 6)
                    .padding(.bottom, 4)

                // ── 헤더 (제목만, 우측 추가 버튼 제거 — 추가 진입점은 리스트 하단 인라인 행) ──
                Text("템플릿 목록")
                    .font(.galBold16())
                    .foregroundColor(.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)

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
                            addNewRow
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
                Text(template.text.isEmpty ? "..." : template.text)
                    .font(.galBold14())
                    .foregroundColor(.ink)
                    .lineLimit(1)
                Spacer(minLength: 4)

                // 편집 버튼
                NavigationLink(destination: TemplateFormView(viewModel: viewModel, editingTemplate: template)) {
                    Text("편집")
                        .font(.galBold13())
                        .foregroundColor(.ink)
                        .padding(.horizontal, 10)
                        .frame(height: 30)
                        .background(Color.cream)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
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

    // MARK: - "+ 새 템플릿" 인라인 행 (리스트 끝 / dashed 보더 톤다운)

    private var addNewRow: some View {
        NavigationLink(destination: TemplateFormView(viewModel: viewModel, editingTemplate: nil)) {
            HStack(spacing: 6) {
                Text("+")
                    .font(.pressStart14())
                    .foregroundColor(.ink.opacity(0.6))
                Text("새 템플릿")
                    .font(.galBold14())
                    .foregroundColor(.ink.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(Color.cream.opacity(0.5))
            .overlay(
                Rectangle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                    .foregroundColor(Color.ink.opacity(0.4))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            Text("★")
                .font(.pressStart34())
                .foregroundColor(.shade.opacity(0.3))
            Text("저장된 템플릿이 없어요")
                .font(.galBold14())
                .foregroundColor(.shade.opacity(0.6))

            NavigationLink(destination: TemplateFormView(viewModel: viewModel, editingTemplate: nil)) {
                HStack(spacing: 6) {
                    Text("+")
                        .font(.pressStart12())
                    Text("새 템플릿 만들기")
                        .font(.galBold13())
                }
                .foregroundColor(.ink)
                .padding(.horizontal, 18)
                .frame(height: 42)
                .background(Color.peach)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
            }
            .padding(.top, 4)
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
