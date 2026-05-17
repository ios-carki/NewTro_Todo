import SwiftUI

struct TodoActionMenuView: View {
    let todo: TodoEntity
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.panel.ignoresSafeArea()

            VStack(spacing: 0) {
                Text(todo.text.isEmpty ? "할일" : todo.text)
                    .font(.galBold14())
                    .foregroundColor(.shade)
                    .lineLimit(1)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)

                VStack(spacing: 8) {
                    if !viewModel.isViewingPastDate {
                        actionRow(title: importanceTitle, icon: "star.fill", color: .sun) {
                            viewModel.updateImportance(id: todo.id, importance: nextImportance)
                            dismiss()
                        }
                        actionRow(title: favoriteTitle, icon: "heart.fill", color: .pixelPink) {
                            viewModel.toggleFavorite(id: todo.id)
                            dismiss()
                        }
                        actionRow(title: "템플릿으로 저장", icon: "square.and.arrow.down", color: .grass) {
                            viewModel.saveTemplate(text: todo.text, importance: todo.importance)
                            dismiss()
                        }
                    }
                    actionRow(title: "삭제", icon: "trash", color: .pixelRed, isDestructive: true) {
                        viewModel.deleteTodo(id: todo.id)
                        dismiss()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                Button { dismiss() } label: {
                    Text("취소")
                        .font(.galBold14())
                        .foregroundColor(.cream)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.pixelRed)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }

    private func actionRow(
        title: LocalizedStringKey,
        icon: String,
        color: Color,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
                Text(title)
                    .font(.galBold14())
                    .foregroundColor(isDestructive ? .pixelRed : .ink)
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(Color.cream)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
        }
    }

    private var importanceTitle: LocalizedStringKey {
        switch todo.importance {
        case .none:   return "중요도: 없음 → 높음"
        case .high:   return "중요도: 높음 → 중간"
        case .medium: return "중요도: 중간 → 없음"
        }
    }

    private var nextImportance: Importance {
        switch todo.importance {
        case .none:   return .high
        case .high:   return .medium
        case .medium: return .none
        }
    }

    private var favoriteTitle: LocalizedStringKey {
        todo.isFavorite ? "즐겨찾기 해제" : "즐겨찾기 추가"
    }
}
