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
                .background(MemoColorPalette.color(for: todo.colorName))
        }
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

    // 텍스트 왼쪽 즐겨찾기 인디케이터는 제거. 우측 토글 버튼 자체가 ON/OFF 상태를 충분히 표현.
    private var textArea: some View {
        let displayText = todo.text.isEmpty ? "..." : todo.text
        return Text(displayText)
            .foregroundColor(todo.isCompleted ? .shade : .ink)
            .font(.galBold14())
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                if isLocked { showLockedToast() } else { openEdit() }
            }
    }

    // MARK: - Trailing favorite toggle
    // 기존 MENU 버튼 자리 즐겨찾기 토글. 인디케이터 사이즈(16)와 동일하게 통일.
    // ON: sun fill 위에 ink outline 겹쳐 밝은 배경에서도 별 윤곽이 또렷.
    // OFF: shade outline 만 — ink 검정은 톤 강해서 부드러운 shade 보라회색으로.
    private var trailingButtons: some View {
        Button {
            if isLocked { showLockedToast(); return }
            viewModel.toggleFavorite(id: todo.id)
        } label: {
            Group {
                if todo.isFavorite {
                    ZStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.sun)
                        Image(systemName: "star")
                            .foregroundColor(.ink)
                    }
                } else {
                    Image(systemName: "star")
                        .foregroundColor(.shade)
                }
            }
            .font(.system(size: 16, weight: .bold))
            .frame(width: 36, height: 36)
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .accessibilityIdentifier("favorite_\(todo.id)")
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
