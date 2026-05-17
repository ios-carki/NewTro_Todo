import SwiftUI

struct TodoRowView: View {
    let todo: TodoEntity
    @ObservedObject var viewModel: MainViewModel
    @State private var offsetX: CGFloat = 0

    init(todo: TodoEntity, viewModel: MainViewModel) {
        self.todo = todo
        self.viewModel = viewModel
    }

    private var isLocked: Bool { viewModel.isViewingPastDate }

    var body: some View {
        HStack(spacing: 0) {
            priorityStrip
                .grayscale(contentGray)
                .opacity(contentOpacity)

            rowContent
        }
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
        .offset(x: offsetX)
        .opacity(offsetX == 0 ? 1 : Double(max(0, 1 - offsetX / 200)))
    }

    // 완료/지난 날짜(잠금) 시 우선순위 스트립·텍스트·우측 버튼은 desaturate + dim.
    // 체크박스만 예외 — 완료 상태에서도 색을 유지해 "완료 해제" affordance 확보. isLocked 일 때만 함께 회색.
    private var contentGray: Double {
        if todo.isCompleted { return 0.85 }
        if isLocked { return 0.7 }
        return 0
    }
    private var contentOpacity: Double {
        if todo.isCompleted { return 0.55 }
        if isLocked { return 0.65 }
        return 1
    }
    private var checkboxGray: Double { isLocked ? 0.7 : 0 }
    private var checkboxOpacity: Double { isLocked ? 0.65 : 1 }

    private func showLockedToast() {
        viewModel.showToast("지난 날의 Todo는 수정할 수 없습니다".localized())
    }

    // MARK: - Priority strip (left 6px)
    private var priorityStrip: some View {
        Rectangle()
            .fill(importanceColor)
            .frame(width: 6)
            .contentShape(Rectangle())
            .onTapGesture {
                if isLocked { showLockedToast() } else { openEdit() }
            }
    }

    // MARK: - Row content
    private var rowContent: some View {
        HStack(spacing: 6) {
            checkboxButton
                .grayscale(checkboxGray)
                .opacity(checkboxOpacity)

            HStack(spacing: 6) {
                textArea
                Spacer(minLength: 4)
                trailingButtons
            }
            .grayscale(contentGray)
            .opacity(contentOpacity)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
    }

    private var checkboxButton: some View {
        Button {
            if isLocked {
                showLockedToast()
                return
            }
            viewModel.toggleComplete(id: todo.id)
        } label: {
            ZStack {
                Rectangle()
                    .fill(todo.isCompleted ? Color.done : Color.panel)
                    .frame(width: 22, height: 22)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))

                if todo.isCompleted {
                    PixelArtView(
                        grid: PixelArtAssets.checkGrid,
                        palette: PixelArtAssets.checkPalette,
                        scale: 2
                    )
                }
            }
        }
        .buttonStyle(.borderless)
        .accessibilityIdentifier("checkbox_\(todo.id)")
    }

    private var textArea: some View {
        HStack(spacing: 4) {
            if todo.isFavorite {
                PixelArtView(
                    grid: PixelArtAssets.favoriteStarGrid,
                    palette: PixelArtAssets.favoriteStarPalette,
                    scale: 1.5
                )
                .opacity(todo.isCompleted ? 0.4 : 1)
            }

            let displayText = todo.text.isEmpty ? "..." : todo.text
            Text(displayText)
                .foregroundColor(todo.isCompleted ? .shade : .ink)
                .font(.galBold14())
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isLocked { showLockedToast() } else { openEdit() }
        }
    }

    private var trailingButtons: some View {
        HStack(spacing: 4) {
            Button {
                viewModel.activeSheet = .actionMenu(todo)
            } label: {
                Text("MENU")
                    .font(.pressStart9())
                    .foregroundColor(.ink)
                    .padding(.horizontal, 6)
                    .frame(height: 28)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))
            }
            .buttonStyle(.borderless)
            .accessibilityIdentifier("action_\(todo.id)")
        }
        .allowsHitTesting(!viewModel.actionMenuRecentlyDismissed)
    }

    // MARK: - Helpers
    private func openEdit() {
        guard !todo.isCompleted else {
            viewModel.showToast("완료한 투두는 수정할 수 없습니다".localized())
            return
        }
        viewModel.presentEditTodo(todo)
    }

    private var importanceColor: Color {
        switch todo.importance {
        case .high:   return .pixelRed
        case .medium: return .sun
        case .none:   return .grass
        }
    }
}
