import SwiftUI

struct TodoActionMenuView: View {
    let todo: TodoEntity
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.panel.ignoresSafeArea()

            VStack(spacing: 0) {
                Capsule()
                    .fill(Color.ink.opacity(0.25))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)

                Text(todo.text.isEmpty ? "할일" : todo.text)
                    .font(.galBold14())
                    .foregroundColor(.shade)
                    .lineLimit(1)
                    .padding(.top, 16)
                    .padding(.horizontal, 20)

                VStack(spacing: 8) {
                    actionRow(title: importanceTitle, icon: "star.fill", color: .sun) {
                        viewModel.updateImportance(id: todo.id, importance: nextImportance)
                        dismiss()
                    }
                    actionRow(title: favoriteTitle, icon: "heart.fill", color: .pixelPink) {
                        viewModel.toggleFavorite(id: todo.id)
                        dismiss()
                    }
                    actionRow(title: "삭제", icon: "trash", color: .pixelRed, isDestructive: true) {
                        viewModel.deleteTodo(id: todo.id)
                        dismiss()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Button { dismiss() } label: {
                    Text("취소")
                        .font(.galBold14())
                        .foregroundColor(.shade)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.ink.opacity(0.08))
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
        }
        .presentationDetents([.fraction(0.42)])
        .presentationDragIndicator(.hidden)
    }

    private func actionRow(
        title: String,
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
            .shadow(color: .ink, radius: 0, x: 2, y: 2)
        }
    }

    private var importanceTitle: String {
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

    private var favoriteTitle: String {
        todo.isFavorite ? "즐겨찾기 해제" : "즐겨찾기 추가"
    }
}
