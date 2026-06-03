import SwiftUI

struct MascotPickerView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @ObservedObject var statsVM: StatsViewModel
    let onShowUnlockInfo: (FriendCharInfo) -> Void
    // 코인 결제 흐름. 잠긴 코인 마스코트의 "해금" 버튼 탭 시 호출되어 confirm 카드를 띄움.
    let onConfirmUnlock: (FriendCharInfo) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var filter: MascotFilter = .all

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    private let selectedCardBg = Color(hex: "#C8EEF7")

    var body: some View {
        ZStack {
            // 탭바가 없는 모달이라 흙 영역을 한 단 줄여 어색함 완화.
            BackgroundSceneryView(groundHeight: TabSceneLayout.modalGroundHeight)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(unlockedSummary)
                            .font(.galBold13())
                            .foregroundColor(.shade)
                        Spacer()
                        walletChip
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    filterBar
                        .padding(.horizontal, 12)

                    mascotContent
                        .padding(.horizontal, 12)
                        .padding(.bottom, TabSceneLayout.contentBottomMargin)
                }
            }
            .clipAboveGround(groundHeight: TabSceneLayout.modalGroundHeight)
        }
        .navigationTitle(Text("마스코트 변경"))
        .navigationBarTitleDisplayMode(.inline)
        // 네비바 배경을 배경화면 상단과 같은 하늘색(.sky)으로 채움. 투명일 때 스크롤 콘텐츠가
        // 네비 영역에 비치던 문제 해결.
        .toolbarBackground(Color.sky, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                closeButton
            }
        }
        .onAppear {
            statsVM.loadStats()
            settingsVM.refreshWalletBalance()
        }
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            PixelArtView(
                grid: PixelArtAssets.dotXGrid,
                palette: PixelArtAssets.dotXPalette,
                scale: 2
            )
            .frame(width: 32, height: 32)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("닫기"))
    }

    private var unlockedSummary: String {
        let unlocked = statsVM.stats.unlockedCharacterIds.count
        return String(format: "%d/%d 해금".localized(), unlocked, CharacterData.all.count)
    }

    // 코인 마스코트 해금 가능 여부 판단용. 잔액을 상단에 항상 노출해 UX 단서를 줌.
    private var walletChip: some View {
        HStack(spacing: 4) {
            PixelArtView(grid: PixelArtAssets.coinGrid,
                         palette: PixelArtAssets.coinPalette,
                         scale: 1.6)
            Text("×\(settingsVM.walletBalance)")
                .font(.pressStart10())
                .foregroundColor(.ink)
        }
        .padding(.horizontal, 8)
        .frame(height: 26)
        .background(Color.cream)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
    }

    // MARK: - Filter

    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(MascotFilter.allCases, id: \.self) { f in
                filterChip(f)
            }
            Spacer(minLength: 0)
        }
    }

    private func filterChip(_ f: MascotFilter) -> some View {
        let isOn = filter == f
        return Button {
            withAnimation(.easeOut(duration: 0.12)) { filter = f }
        } label: {
            Text(f.label)
                .font(.galBold13())
                .foregroundColor(isOn ? .cream : .ink)
                .padding(.horizontal, 12)
                .frame(height: 28)
                .background(isOn ? Color.ink : Color.cream)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Content

    @ViewBuilder
    private var mascotContent: some View {
        let owned   = CharacterData.all.filter { statsVM.stats.unlockedCharacterIds.contains($0.id) }
        let locked  = CharacterData.all.filter { !statsVM.stats.unlockedCharacterIds.contains($0.id) }

        switch filter {
        case .all:
            VStack(alignment: .leading, spacing: 12) {
                if !owned.isEmpty {
                    sectionHeader(titleKey: "보유중", count: owned.count, icon: "checkmark.seal.fill")
                        .padding(.top, 4)
                    grid(items: owned)
                }
                if !locked.isEmpty {
                    sectionHeader(titleKey: "미보유", count: locked.count, icon: "lock.fill")
                        .padding(.top, 12)
                    grid(items: locked)
                }
            }
        case .owned:
            grid(items: owned)
        case .locked:
            grid(items: locked)
        }
    }

    private func grid(items: [FriendCharInfo]) -> some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(items) { info in
                mascotCard(info)
            }
        }
    }

    private func sectionHeader(titleKey: String, count: Int, icon: String) -> some View {
        HStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.ink)
                Text(LocalizedStringKey(titleKey))
                    .font(.galBold13())
                    .foregroundColor(.ink)
                Text("\(count)")
                    .font(.pressStart9())
                    .foregroundColor(.shade)
            }
            .padding(.horizontal, 10)
            .frame(height: 28)
            .background(Color.cream)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))

            Spacer(minLength: 0)
        }
        .padding(.leading, 2)
    }

    // MARK: - Card
    private func mascotCard(_ info: FriendCharInfo) -> some View {
        let isUnlocked = statsVM.stats.unlockedCharacterIds.contains(info.id)
        let isSelected = settingsVM.selectedCharacterId == info.id
        // 코인 해금 마스코트는 잠겨 있어도 이름/설명을 미리 공개해 무엇을 사는지 보이게 한다.
        let revealsText = isUnlocked || info.unlockCost != nil

        return PixelPanel(bg: isSelected ? selectedCardBg : .panel, padding: 10) {
            VStack(spacing: 8) {
                portrait(info: info)

                Text(revealsText ? LocalizedStringKey(info.name) : LocalizedStringKey("???"))
                    .font(.galBold16())
                    .foregroundColor(revealsText ? .ink : .shade.opacity(0.5))
                    .lineLimit(1)

                Rectangle()
                    .fill(Color.ink.opacity(0.2))
                    .frame(height: 1)
                    .padding(.horizontal, 4)

                Text(revealsText ? LocalizedStringKey(info.description) : LocalizedStringKey("???"))
                    .font(.galBold11())
                    .foregroundColor(revealsText ? .shade : .shade.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, minHeight: 38, alignment: .top)

                actionButtons(info: info, isUnlocked: isUnlocked, isSelected: isSelected)
            }
        }
        .overlay(alignment: .topTrailing) {
            if isSelected {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.sun)
                    .background(Circle().fill(Color.ink).frame(width: 14, height: 14))
                    .offset(x: 4, y: -4)
            }
        }
    }

    private func portrait(info: FriendCharInfo) -> some View {
        ZStack {
            Color.mascotTile
                .frame(width: 76, height: 76)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))

            PixelArtView(
                grid: PixelArtAssets.characterGrid(type: info.gridType),
                palette: info.palette,
                scale: 5
            )
        }
    }

    @ViewBuilder
    private func actionButtons(info: FriendCharInfo, isUnlocked: Bool, isSelected: Bool) -> some View {
        HStack(spacing: 4) {
            Button {
                presentUnlockInfo(info)
            } label: {
                Text("획득방법")
                    .font(.galBold11())
                    .foregroundColor(.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
            }
            .buttonStyle(.plain)

            if isUnlocked {
                if isSelected {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                        Text("선택됨")
                            .font(.galBold11())
                    }
                    .foregroundColor(.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
                    .background(Color.sun)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
                } else {
                    Button {
                        settingsVM.selectedCharacterId = info.id
                    } label: {
                        Text("적용하기")
                            .font(.galBold11())
                            .foregroundColor(.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 28)
                            .background(Color.grass)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
                    }
                    .buttonStyle(.plain)
                }
            } else if let cost = info.unlockCost {
                coinUnlockButton(cost: cost, info: info)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                    Text("잠김")
                        .font(.galBold11())
                }
                .foregroundColor(.shade)
                .frame(maxWidth: .infinity)
                .frame(height: 28)
                .background(Color.cream.opacity(0.4))
                .overlay(Rectangle().stroke(Color.ink.opacity(0.3), lineWidth: 1.5))
            }
        }
    }

    // 잠긴 코인 마스코트의 해금 CTA. 잔액 충분 → sun bg 액티브 / 부족 → 흐릿한 disabled.
    @ViewBuilder
    private func coinUnlockButton(cost: Int, info: FriendCharInfo) -> some View {
        let canAfford = settingsVM.walletBalance >= cost

        Button {
            guard canAfford else { return }
            onConfirmUnlock(info)
        } label: {
            HStack(spacing: 3) {
                PixelArtView(grid: PixelArtAssets.coinGrid,
                             palette: PixelArtAssets.coinPalette,
                             scale: 1.2)
                Text("\(cost)")
                    .font(.pressStart9())
                    .foregroundColor(canAfford ? .ink : .shade.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 28)
            .background(canAfford ? Color.sun : Color.cream.opacity(0.4))
            .overlay(Rectangle().stroke(canAfford ? Color.ink : Color.ink.opacity(0.3),
                                        lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .disabled(!canAfford)
    }

    // MARK: - Unlock Info Popup
    private func presentUnlockInfo(_ info: FriendCharInfo) {
        onShowUnlockInfo(info)
    }
}

// MARK: - Unlock Info Card
private struct UnlockInfoCard: View {
    let info: FriendCharInfo
    let onClose: () -> Void

    var body: some View {
        PixelPanel(bg: .cream, padding: 20) {
            VStack(spacing: 14) {
                ZStack {
                    Color.mascotTile
                        .frame(width: 96, height: 96)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    PixelArtView(
                        grid: PixelArtAssets.characterGrid(type: info.gridType),
                        palette: info.palette,
                        scale: 7
                    )
                }

                Text(LocalizedStringKey(info.name))
                    .font(.galBold16())
                    .foregroundColor(.ink)

                Rectangle()
                    .fill(Color.ink.opacity(0.25))
                    .frame(height: 1)
                    .padding(.horizontal, 12)

                Text("획득 조건")
                    .font(.galBold11())
                    .foregroundColor(.shade)

                // 코인 마스코트는 "N 코인으로 잠금 해제" 형태로 가격을 직접 표시.
                // 통계 기반 마스코트는 unlockDescription 키 그대로 (예: "투두 5개 완료").
                if let cost = info.unlockCost {
                    Text(String(format: "%d 코인으로 잠금 해제".localized(), cost))
                        .font(.galBold14())
                        .foregroundColor(.ink)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                } else {
                    Text(LocalizedStringKey(info.unlockDescription))
                        .font(.galBold14())
                        .foregroundColor(.ink)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }

                // 코인 마스코트는 가격 칩으로 시각적 강조 추가.
                if let cost = info.unlockCost {
                    HStack(spacing: 6) {
                        PixelArtView(grid: PixelArtAssets.coinGrid,
                                     palette: PixelArtAssets.coinPalette,
                                     scale: 1.6)
                        Text("×\(cost)")
                            .font(.pressStart12())
                            .foregroundColor(.ink)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.sun.opacity(0.6))
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
                }

                Button(action: onClose) {
                    Text("확인")
                        .font(.galBold14())
                        .foregroundColor(.cream)
                        .padding(.horizontal, 24)
                        .frame(height: 32)
                        .background(Color.ink)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - Mascot Unlock Confirm Card
// 코인 결제로 마스코트를 해금하기 직전 사용자 확인 카드.
private struct MascotUnlockConfirmCard: View {
    let info: FriendCharInfo
    let balance: Int
    let isUnlocking: Bool
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        PixelPanel(bg: .cream, padding: 20) {
            VStack(spacing: 12) {
                ZStack {
                    Color.mascotTile
                        .frame(width: 96, height: 96)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    PixelArtView(
                        grid: PixelArtAssets.characterGrid(type: info.gridType),
                        palette: info.palette,
                        scale: 7
                    )
                }

                Text(LocalizedStringKey(info.name))
                    .font(.galBold16())
                    .foregroundColor(.ink)

                Rectangle()
                    .fill(Color.ink.opacity(0.25))
                    .frame(height: 1)
                    .padding(.horizontal, 12)

                if let cost = info.unlockCost {
                    HStack(spacing: 6) {
                        PixelArtView(grid: PixelArtAssets.coinGrid,
                                     palette: PixelArtAssets.coinPalette,
                                     scale: 1.8)
                        Text("×\(cost)")
                            .font(.pressStart12())
                            .foregroundColor(.ink)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.sun.opacity(0.6))
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
                }

                Text("코인을 사용해 해금하시겠어요?")
                    .font(.galBold13())
                    .foregroundColor(.ink)
                    .multilineTextAlignment(.center)

                HStack(spacing: 4) {
                    Text("보유")
                        .font(.galBold11())
                        .foregroundColor(.shade)
                    PixelArtView(grid: PixelArtAssets.coinGrid,
                                 palette: PixelArtAssets.coinPalette,
                                 scale: 1.2)
                    Text("×\(balance)")
                        .font(.pressStart9())
                        .foregroundColor(.shade)
                }
                .padding(.top, 2)

                HStack(spacing: 10) {
                    Button(action: onCancel) {
                        Text("취소")
                            .font(.galBold14())
                            .foregroundColor(.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(Color.cream)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                    .disabled(isUnlocking)

                    Button(action: onConfirm) {
                        Text(isUnlocking ? "해금중..." : "해금")
                            .font(.galBold14())
                            .foregroundColor(.cream)
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(Color.peachDk)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                    .disabled(isUnlocking)
                }
                .padding(.top, 6)
            }
        }
    }
}

// MARK: - Cover Wrapper
// fullScreenCover 안에서 NavigationView 를 감싸 dim+팝업이 nav bar 위에 오버레이되도록 하는 컨테이너.
// 팝업 상태(unlockInfoTarget / unlockConfirmTarget)를 여기서 소유하고 자식에 콜백으로 전달.
struct MascotPickerCover: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @ObservedObject var statsVM: StatsViewModel
    @State private var unlockInfoTarget: FriendCharInfo?
    @State private var unlockConfirmTarget: FriendCharInfo?
    @State private var isUnlocking: Bool = false

    var body: some View {
        NavigationView {
            MascotPickerView(
                settingsVM: settingsVM,
                statsVM: statsVM,
                onShowUnlockInfo: { unlockInfoTarget = $0 },
                onConfirmUnlock: { unlockConfirmTarget = $0 }
            )
        }
        .navigationViewStyle(.stack)
        .overlay {
            if let target = unlockInfoTarget {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { unlockInfoTarget = nil }

                    UnlockInfoCard(info: target, onClose: { unlockInfoTarget = nil })
                        .padding(.horizontal, 32)
                }
            }
            if let target = unlockConfirmTarget {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            // 트랜잭션 중에는 dim 탭으로 닫지 못하게 막아 중복 처리 방지.
                            if !isUnlocking { unlockConfirmTarget = nil }
                        }

                    MascotUnlockConfirmCard(
                        info: target,
                        balance: settingsVM.walletBalance,
                        isUnlocking: isUnlocking,
                        onCancel: { unlockConfirmTarget = nil },
                        onConfirm: { performUnlock(info: target) }
                    )
                    .padding(.horizontal, 32)
                }
            }
        }
    }

    // 코인 차감 → unlocked 집합 추가 → walletBalance 새로고침 → statsVM 새로고침 → 자동 선택까지.
    // 자동 선택: 갓 해금한 마스코트는 곧바로 적용해서 "획득했어요" 분위기를 만든다.
    private func performUnlock(info: FriendCharInfo) {
        guard let cost = info.unlockCost else { return }
        guard !isUnlocking else { return }
        isUnlocking = true
        Task {
            do {
                try await settingsVM.unlockMascot(id: info.id, cost: cost)
                statsVM.loadStats()
                settingsVM.selectedCharacterId = info.id
            } catch {
                // 잔액 부족 등 방어 경로. UI 단에서 이미 disabled 처리되므로 정상 흐름에선 발생하지 않음.
            }
            unlockConfirmTarget = nil
            isUnlocking = false
        }
    }
}

// MARK: - Filter Enum

enum MascotFilter: CaseIterable {
    case all, owned, locked

    var label: LocalizedStringKey {
        switch self {
        case .all:    return "전체"
        case .owned:  return "보유중만 보기"
        case .locked: return "미보유만 보기"
        }
    }
}
