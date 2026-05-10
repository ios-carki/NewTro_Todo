import SwiftUI

struct MascotPickerView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @ObservedObject var statsVM: StatsViewModel

    @State private var unlockInfo: FriendCharInfo?
    @State private var filter: MascotFilter = .all

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    private let selectedCardBg = Color(hex: "#C8EEF7")

    var body: some View {
        ZStack {
            Color.sky.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(unlockedSummary)
                            .font(.pressStart7())
                            .foregroundColor(.shade)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    filterBar
                        .padding(.horizontal, 12)

                    mascotContent
                        .padding(.horizontal, 12)
                        .padding(.bottom, 120)
                }
            }
        }
        .navigationTitle(Text("마스코트 변경"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { statsVM.loadStats() }
        .overlay {
            if let info = unlockInfo {
                unlockInfoOverlay(info)
            }
        }
    }

    private var unlockedSummary: String {
        let unlocked = statsVM.stats.unlockedCharacterIds.count
        return String(format: "%d/%d 해금".localized(), unlocked, CharacterData.all.count)
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
                .font(.pressStart7())
                .foregroundColor(isOn ? .cream : .ink)
                .padding(.horizontal, 12)
                .frame(height: 26)
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
                    sectionHeader(title: "OWNED", count: owned.count, icon: "checkmark.seal.fill")
                        .padding(.top, 4)
                    grid(items: owned)
                }
                if !locked.isEmpty {
                    sectionHeader(title: "LOCKED", count: locked.count, icon: "lock.fill")
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

    private func sectionHeader(title: String, count: Int, icon: String) -> some View {
        HStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.ink)
                Text("\(title)  \(count)")
                    .font(.pressStart9())
                    .foregroundColor(.ink)
            }
            .padding(.horizontal, 10)
            .frame(height: 26)
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

        return PixelPanel(bg: isSelected ? selectedCardBg : .panel, padding: 10) {
            VStack(spacing: 8) {
                portrait(info: info)

                Text(isUnlocked ? LocalizedStringKey(info.name) : LocalizedStringKey("???"))
                    .font(.pressStart9())
                    .foregroundColor(isUnlocked ? .ink : .shade.opacity(0.5))
                    .lineLimit(1)

                Rectangle()
                    .fill(Color.ink.opacity(0.2))
                    .frame(height: 1)
                    .padding(.horizontal, 4)

                Text(isUnlocked ? LocalizedStringKey(info.description) : LocalizedStringKey("???"))
                    .font(.galBold11())
                    .foregroundColor(isUnlocked ? .shade : .shade.opacity(0.4))
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
            Color.cream
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
                withAnimation(.easeInOut(duration: 0.15)) { unlockInfo = info }
            } label: {
                Text("획득방법")
                    .font(.pressStart7())
                    .foregroundColor(.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 24)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
            }
            .buttonStyle(.plain)

            if isUnlocked {
                if isSelected {
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                        Text("선택됨")
                            .font(.pressStart7())
                    }
                    .foregroundColor(.cream)
                    .frame(maxWidth: .infinity)
                    .frame(height: 24)
                    .background(Color.sun)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
                } else {
                    Button {
                        settingsVM.selectedCharacterId = info.id
                    } label: {
                        Text("적용하기")
                            .font(.pressStart7())
                            .foregroundColor(.cream)
                            .frame(maxWidth: .infinity)
                            .frame(height: 24)
                            .background(Color.grass)
                            .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
                    }
                    .buttonStyle(.plain)
                }
            } else {
                HStack(spacing: 3) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 9))
                    Text("잠김")
                        .font(.pressStart7())
                }
                .foregroundColor(.shade)
                .frame(maxWidth: .infinity)
                .frame(height: 24)
                .background(Color.cream.opacity(0.4))
                .overlay(Rectangle().stroke(Color.ink.opacity(0.3), lineWidth: 1.5))
            }
        }
    }

    // MARK: - Unlock Info Popup
    private func unlockInfoOverlay(_ info: FriendCharInfo) -> some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.15)) { unlockInfo = nil }
                }

            VStack(spacing: 14) {
                ZStack {
                    Color.cream
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
                    .font(.pressStart7())
                    .foregroundColor(.shade)

                Text(LocalizedStringKey(info.unlockDescription))
                    .font(.galBold14())
                    .foregroundColor(.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                Button {
                    withAnimation(.easeOut(duration: 0.15)) { unlockInfo = nil }
                } label: {
                    Text("확인")
                        .font(.pressStart9())
                        .foregroundColor(.cream)
                        .padding(.horizontal, 24)
                        .frame(height: 32)
                        .background(Color.ink)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(20)
            .background(Color.panel)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
            .padding(.horizontal, 40)
            .transition(.opacity)
        }
    }
}

// MARK: - Filter Enum

enum MascotFilter: CaseIterable {
    case all, owned, locked

    var label: LocalizedStringKey {
        switch self {
        case .all:    return "ALL"
        case .owned:  return "OWNED"
        case .locked: return "LOCKED"
        }
    }
}
