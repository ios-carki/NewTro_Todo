import SwiftUI

// 앱 전체에서 공용으로 쓰이는 popup 컨테이너.
// RootTabContainerView 가 단일 호스트로서 dim + 컨텐츠를 floating tab bar 위 zIndex 에 렌더링하므로
// 상단 safe area / nav bar / 하단 탭바까지 dim 이 덮고 popup 영역만 터치 가능해진다.
// 내부 컨텐츠는 dim 을 직접 그리지 않고 카드만 반환할 것.
@MainActor
final class PopupCenter: ObservableObject {
    @Published private(set) var item: Item?

    struct Item: Identifiable {
        let id = UUID()
        let view: AnyView
        // dim 영역(컨텐츠 바깥) 탭으로 dismiss 허용 여부. confirm popup 등에서 false 권장.
        let dismissOnBackgroundTap: Bool
    }

    func present<V: View>(
        dismissOnBackgroundTap: Bool = true,
        @ViewBuilder _ content: () -> V
    ) {
        let v = AnyView(content())
        item = Item(view: v, dismissOnBackgroundTap: dismissOnBackgroundTap)
    }

    func dismiss() {
        item = nil
    }
}
