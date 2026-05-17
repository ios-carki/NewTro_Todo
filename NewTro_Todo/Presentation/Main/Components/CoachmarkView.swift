import SwiftUI

// MARK: - Anchor Preference

struct CoachmarkAnchorKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

extension View {
    func coachmarkAnchor(_ id: String) -> some View {
        anchorPreference(key: CoachmarkAnchorKey.self, value: .bounds) { [id: $0] }
    }
}

// MARK: - Step Data

struct CoachmarkStep: Identifiable {
    let id: String
    let title: String
    let message: String
}

enum CoachmarkSteps {
    static let main: [CoachmarkStep] = [
        .init(id: "hud_coin",  title: "COIN",   message: "그 날 완료한 Todo로 모은 보상이야"),
        .init(id: "hud_heart", title: "HEART",  message: "오늘 추가한 Todo만큼 차오르고, 미루면 줄어들어"),
        .init(id: "warp",      title: "WARP",   message: "다른 날짜로 이동할 수 있어"),
        .init(id: "sort",      title: "SORT",   message: "Todo 순서를 직접 정렬해"),
        .init(id: "add_todo",  title: "+ TODO", message: "새 할 일을 추가하자")
    ]
}

// MARK: - Overlay

struct CoachmarkOverlay: View {
    @Binding var isActive: Bool
    @State private var stepIndex: Int = 0
    let steps: [CoachmarkStep]
    let anchors: [String: Anchor<CGRect>]
    let geom: GeometryProxy

    private var currentStep: CoachmarkStep? {
        guard stepIndex < steps.count else { return nil }
        return steps[stepIndex]
    }
    private var currentRect: CGRect? {
        guard let step = currentStep, let anchor = anchors[step.id] else { return nil }
        return geom[anchor]
    }

    var body: some View {
        if let step = currentStep {
            ZStack {
                dimBackground
                spotlightBorder
                bubble(step)
            }
            .transition(.opacity)
        }
    }

    private var dimBackground: some View {
        Rectangle()
            .fill(Color.black.opacity(0.7))
            .reverseMask {
                if let rect = currentRect {
                    Rectangle()
                        .frame(width: rect.width + 8, height: rect.height + 8)
                        .position(x: rect.midX, y: rect.midY)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { }
    }

    @ViewBuilder
    private var spotlightBorder: some View {
        if let rect = currentRect {
            Rectangle()
                .stroke(Color.sun, lineWidth: 3)
                .frame(width: rect.width + 8, height: rect.height + 8)
                .position(x: rect.midX, y: rect.midY)
                .allowsHitTesting(false)
        }
    }

    private func bubble(_ step: CoachmarkStep) -> some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(LocalizedStringKey(step.title))
                        .font(.pressStart12())
                        .foregroundColor(.ink)
                    Spacer()
                    Text("\(stepIndex + 1) / \(steps.count)")
                        .font(.pressStart9())
                        .foregroundColor(.shade)
                }
                Text(LocalizedStringKey(step.message))
                    .font(.galBold16())
                    .foregroundColor(.ink)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    Button(action: skip) {
                        Text("건너뛰기")
                            .font(.galBold14())
                            .foregroundColor(.shade)
                            .padding(.horizontal, 10)
                            .frame(height: 36)
                            .background(Color.cream)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    }
                    .buttonStyle(.borderless)
                    Spacer()
                    if stepIndex > 0 {
                        Button(action: previous) {
                            Text("◀ 이전")
                                .font(.galBold14())
                                .foregroundColor(.ink)
                                .padding(.horizontal, 12)
                                .frame(height: 36)
                                .background(Color.cream)
                                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                                .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
                        }
                        .buttonStyle(.borderless)
                    }
                    Button(action: advance) {
                        Text(stepIndex < steps.count - 1 ? "다음 ▶" : "시작!")
                            .font(.galBold14())
                            .foregroundColor(.ink)
                            .padding(.horizontal, 14)
                            .frame(height: 36)
                            .background(Color.peach)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                            .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(14)
            .background(Rectangle().fill(Color.panel))
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    private func advance() {
        if stepIndex < steps.count - 1 {
            withAnimation(.easeInOut(duration: 0.2)) { stepIndex += 1 }
        } else {
            finish()
        }
    }

    private func previous() {
        guard stepIndex > 0 else { return }
        withAnimation(.easeInOut(duration: 0.2)) { stepIndex -= 1 }
    }

    private func skip() { finish() }

    private func finish() {
        withAnimation(.easeOut(duration: 0.25)) {
            isActive = false
        }
        stepIndex = 0
    }
}

// MARK: - Notification

extension Notification.Name {
    static let replayTodoCoachmark = Notification.Name("replayTodoCoachmark")
}

// MARK: - Reverse Mask

extension View {
    func reverseMask<Mask: View>(@ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask(
            Rectangle()
                .overlay(mask().blendMode(.destinationOut))
                .compositingGroup()
        )
    }
}
