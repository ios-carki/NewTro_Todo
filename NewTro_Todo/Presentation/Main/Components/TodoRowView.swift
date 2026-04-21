import SwiftUI

struct TodoRowView: View {
    let todo: TodoEntity
    @ObservedObject var viewModel: MainViewModel
    @State private var editingText: String
    @State private var offsetX: CGFloat = 0

    init(todo: TodoEntity, viewModel: MainViewModel) {
        self.todo = todo
        self.viewModel = viewModel
        self._editingText = State(initialValue: todo.text)
    }

    var body: some View {
        HStack(spacing: 0) {
            priorityStrip
            rowContent
        }
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
        .offset(x: offsetX)
        .opacity(offsetX == 0 ? 1 : Double(max(0, 1 - offsetX / 200)))
    }

    // MARK: - Priority strip (left 6px)
    private var priorityStrip: some View {
        Rectangle()
            .fill(importanceColor)
            .frame(width: 6)
    }

    // MARK: - Row content
    private var rowContent: some View {
        HStack(spacing: 6) {
            checkboxButton
            textArea
            Spacer(minLength: 4)
            trailingButtons
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
    }

    private var checkboxButton: some View {
        Button {
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
    }

    private var textArea: some View {
        HStack(spacing: 4) {
            if todo.isCompleted {
                Text(todo.text.isEmpty ? "..." : todo.text)
                    .strikethrough(color: .shade)
                    .foregroundColor(.shade)
                    .font(.galBold14())
                    .lineLimit(1)
            } else {
                TextField("할일을 입력하세요", text: $editingText)
                    .foregroundColor(.ink)
                    .font(.galBold14())
                    .onSubmit { viewModel.updateText(id: todo.id, text: editingText) }
                    .onChange(of: editingText) { newValue in
                        let capped = String(newValue.prefix(50))
                        if capped != newValue { editingText = capped }
                        viewModel.updateText(id: todo.id, text: capped)
                    }
            }

            if todo.postponeCount > 0 {
                postponeBadge
            }
        }
    }

    private var postponeBadge: some View {
        HStack(spacing: 1) {
            Text("🕐")
                .font(.system(size: 9))
            Text("×\(todo.postponeCount)")
                .font(.pressStart7())
                .foregroundColor(todo.postponeCount >= 3 ? .white : .ink)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(todo.postponeCount >= 3 ? Color.redDk : Color.cream)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))
    }

    private var trailingButtons: some View {
        HStack(spacing: 4) {
            Button {
                viewModel.postponeTarget = todo
            } label: {
                Text("🕐")
                    .font(.system(size: 16))
                    .frame(width: 28, height: 28)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))
            }

            Button {
                viewModel.actionTarget = todo
            } label: {
                Text("⋯")
                    .font(.galBold16())
                    .foregroundColor(.shade)
                    .frame(width: 28, height: 28)
                    .background(Color.panel)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))
            }
        }
    }

    // MARK: - Helpers
    private var importanceColor: Color {
        switch todo.importance {
        case .high:   return .pixelRed
        case .medium: return .sun
        case .none:   return .grass
        }
    }
}
