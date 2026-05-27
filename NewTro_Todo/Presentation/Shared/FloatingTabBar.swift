import SwiftUI

// 탭 선택/리셋 상태를 보유. RootTabContainerView 가 @StateObject 로 소유하고
// 각 탭 콘텐츠에 @EnvironmentObject 로 주입한다. FloatingTabBar 가 이 상태를 읽고 쓰며
// 탭 컨테이너는 selected 변화를 관찰해 화면을 전환한다.
@MainActor
final class TabBarController: ObservableObject {
    @Published var selected: AppTab = .todo
    @Published var todoTabId     = UUID()
    @Published var memoTabId     = UUID()
    @Published var routineTabId  = UUID()
    @Published var statsTabId    = UUID()
    @Published var settingsTabId = UUID()

    // 코치마크/튜토리얼 등 모달성 오버레이가 활성일 때 true.
    // true 일 동안 사용자 탭 입력은 무시 — 코치마크가 등장하기 직전 0.6초 delay 구간에서
    // 빠르게 다른 탭을 눌러 빠져나가던 버그를 방지하기 위한 게이트.
    // (직접 `selected = ...` 할당은 그대로 허용 — 시스템/replay 트리거가 자유롭게 라우팅 가능)
    @Published var inputBlocked: Bool = false

    func selectOrReset(_ tab: AppTab) {
        guard !inputBlocked else { return }
        if selected == tab {
            resetTab(tab)
        } else {
            selected = tab
        }
    }

    private func resetTab(_ tab: AppTab) {
        switch tab {
        case .todo:     todoTabId = UUID()
        case .memo:     memoTabId = UUID()
        case .routine:  routineTabId = UUID()
        case .stats:    statsTabId = UUID()
        case .settings: settingsTabId = UUID()
        }
    }
}

// 4-탭 floating tab bar. 각 탭 콘텐츠 내부에서 .overlay(alignment: .bottom) 로 렌더링되어
// NavigationView push 시 push 된 화면이 자연스럽게 덮는다. 별도 hide/show 토글 없음.
// 흙+잔디 ground strip 은 BackgroundSceneryView 에 포함되어 push 시에도 배경으로 유지됨.
struct FloatingTabBar: View {
    @EnvironmentObject private var controller: TabBarController

    var body: some View {
        // overlay 컨테이너는 parent 의 safe area 안쪽으로 bound 되므로,
        // VStack + Spacer 로 화면 전체 높이를 점유하고 .ignoresSafeArea 로 물리 bottom 까지 확장.
        // 그렇게 해야 tab bar 가 물리 bottom 에서 16pt 떠 있는 원래 root-level 레이아웃과 동일해진다.
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            tabBar
                .padding(.horizontal, 14)
                .padding(.bottom, 16)
                // 코치마크 active 동안 시각 press 피드백도 차단 (탭 라우팅 차단은 controller 단에서).
                .allowsHitTesting(!controller.inputBlocked)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabItem(.todo,     label: "할일", sfSymbol: "checkmark.square.fill")
            tabItem(.memo,     label: "메모", sfSymbol: "pencil")
            tabItem(.routine,  label: "루틴", sfSymbol: "repeat")
            tabItem(.stats,    label: "통계", sfSymbol: "chart.bar.fill")
            tabItem(.settings, label: "설정", sfSymbol: "gearshape.fill")
        }
        .frame(height: 62)
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 3))
        .background(Rectangle().fill(Color.ink).offset(x: 4, y: 4))
        .clipped()
    }

    private func tabItem(_ tab: AppTab, label: LocalizedStringKey, sfSymbol: String) -> some View {
        let isActive = controller.selected == tab
        return Button {
            controller.selectOrReset(tab)
        } label: {
            VStack(spacing: 5) {
                Spacer(minLength: 0)

                if isActive {
                    ZStack {
                        Rectangle()
                            .fill(Color.ink)
                            .frame(width: 38, height: 30)
                            .offset(x: 2, y: 2)
                        Rectangle()
                            .fill(Color.sun)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                            .frame(width: 38, height: 30)
                        Image(systemName: sfSymbol)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.ink)
                    }
                } else {
                    Image(systemName: sfSymbol)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.shade)
                        .frame(width: 38, height: 30)
                }

                Text(label)
                    .font(.galBold14())
                    .foregroundColor(isActive ? .ink : .shade)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
