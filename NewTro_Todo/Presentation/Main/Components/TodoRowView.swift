import SwiftUI

struct TodoRowView: View {
    let todo: TodoEntity
    @ObservedObject var viewModel: MainViewModel
    @State private var offsetX: CGFloat = 0
    @State private var showFireworks: Bool = false

    init(todo: TodoEntity, viewModel: MainViewModel) {
        self.todo = todo
        self.viewModel = viewModel
    }

    private var isLocked: Bool { viewModel.isViewingPastDate }

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                priorityStrip
                rowContent
            }
            .background(Color.panel)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
            .offset(x: offsetX)
            .opacity(offsetX == 0 ? 1 : Double(max(0, 1 - offsetX / 200)))
            .grayscale(isLocked ? 0.7 : 0)
            .opacity(isLocked ? 0.65 : 1)

            if showFireworks {
                FireworksView()
                    .allowsHitTesting(false)
            }
        }
    }

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
            textArea
            Spacer(minLength: 4)
            trailingButtons
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
            if !todo.isCompleted {
                showFireworks = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { showFireworks = false }
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

            if !todo.emoji.isEmpty {
                Text(todo.emoji)
                    .font(.system(size: 14))
            }

            let displayText = todo.text.isEmpty ? "..." : todo.text
            Text(displayText)
                .strikethrough(todo.isCompleted, color: .shade)
                .foregroundColor(todo.isCompleted ? .shade : .ink)
                .font(.galBold14())
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            if todo.postponeCount > 0 {
                postponeBadge
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isLocked { showLockedToast() } else { openEdit() }
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
                if isLocked {
                    showLockedToast()
                } else {
                    viewModel.activeSheet = .postpone(todo)
                }
            } label: {
                Text("ZZZ")
                    .font(.pressStart7())
                    .foregroundColor(.ink)
                    .padding(.horizontal, 6)
                    .frame(height: 28)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))
            }
            .buttonStyle(.borderless)
            .accessibilityIdentifier("postpone_\(todo.id)")

            Button {
                viewModel.activeSheet = .actionMenu(todo)
            } label: {
                Text("MENU")
                    .font(.pressStart7())
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

// MARK: - Fireworks
private struct FireworksView: View {
    private let particles: [FireParticle] = (0..<12).map { _ in FireParticle() }
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(particles.indices, id: \.self) { i in
                let p = particles[i]
                Circle()
                    .fill(p.color)
                    .frame(width: p.size, height: p.size)
                    .offset(
                        x: animate ? p.endX : 0,
                        y: animate ? p.endY : 0
                    )
                    .opacity(animate ? 0 : 1)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) { animate = true }
        }
    }
}

private struct FireParticle {
    let color: Color
    let size: CGFloat
    let endX: CGFloat
    let endY: CGFloat

    init() {
        let angle = Double.random(in: 0..<360) * .pi / 180
        let dist = CGFloat.random(in: 24...48)
        color = [Color.sun, .pixelRed, .grass, .pixelPink, .done].randomElement() ?? .sun
        size = CGFloat.random(in: 3...6)
        endX = cos(angle) * dist
        endY = sin(angle) * dist
    }
}
