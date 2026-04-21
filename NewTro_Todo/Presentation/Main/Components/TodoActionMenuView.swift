import SwiftUI

struct TodoActionMenuView: View {
    let todo: TodoEntity
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(UIColor.mainBackGroundColor).ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle bar
                Capsule()
                    .frame(width: 40, height: 4)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 12)

                VStack(spacing: 1) {
                    actionRow(title: importanceTitle, icon: "star.fill") {
                        viewModel.updateImportance(id: todo.id, importance: nextImportance)
                        dismiss()
                    }

                    actionRow(title: favoriteTitle, icon: "heart.fill") {
                        viewModel.toggleFavorite(id: todo.id)
                        dismiss()
                    }

                    actionRow(title: "삭제", icon: "trash", isDestructive: true) {
                        viewModel.deleteTodo(id: todo.id)
                        dismiss()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)

                Button("취소") { dismiss() }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
            }
        }
        .presentationDetents([.fraction(0.35)])
        .presentationDragIndicator(.hidden)
    }

    private func actionRow(
        title: String,
        icon: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isDestructive ? .red : .white)
                Text(title)
                    .foregroundColor(isDestructive ? .red : .white)
                    .font(.galBold16())
                Spacer()
            }
            .padding()
            .background(Color.textFieldC)
        }
    }

    private var importanceTitle: String {
        switch todo.importance {
        case .none:   return "중요도 설정 (없음 → 높음)"
        case .high:   return "중요도 설정 (높음 → 중간)"
        case .medium: return "중요도 설정 (중간 → 없음)"
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
