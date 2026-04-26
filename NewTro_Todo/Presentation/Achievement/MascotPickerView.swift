import SwiftUI

struct MascotPickerView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @ObservedObject var statsVM: StatsViewModel

    private let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        ZStack {
            Color.sky.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("보유 캐릭터 중 마스코트를 선택해요")
                        .font(.pressStart7())
                        .foregroundColor(.shade)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    let ownedChars = CharacterData.all.filter {
                        statsVM.stats.unlockedCharacterIds.contains($0.id)
                    }

                    if ownedChars.isEmpty {
                        emptyState
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(ownedChars) { charInfo in
                                MascotCell(
                                    info: charInfo,
                                    isSelected: settingsVM.selectedCharacterId == charInfo.id
                                ) {
                                    settingsVM.selectedCharacterId = charInfo.id
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("마스코트 변경")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { statsVM.loadStats() }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("아직 해금된 캐릭터가 없어요")
                .font(.galBold14())
                .foregroundColor(.shade)
            Text("도전과제를 달성해서\n친구를 만나보세요!")
                .font(.pressStart7())
                .foregroundColor(.shade.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

// MARK: - Mascot Cell
private struct MascotCell: View {
    let info: FriendCharInfo
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                ZStack {
                    (isSelected ? Color.sun.opacity(0.3) : Color.panel)
                        .frame(width: 72, height: 72)
                        .overlay(
                            Rectangle().stroke(
                                isSelected ? Color.ink : Color.ink.opacity(0.3),
                                lineWidth: isSelected ? 3 : 1.5
                            )
                        )

                    PixelArtView(
                        grid: PixelArtAssets.characterGrid(type: info.gridType),
                        palette: info.palette,
                        scale: 6
                    )

                    if isSelected {
                        VStack {
                            Spacer()
                            Text("선택됨")
                                .font(.pressStart7())
                                .foregroundColor(.ink)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.sun)
                                .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))
                        }
                        .frame(width: 72, height: 72)
                    }
                }

                Text(info.name)
                    .font(.pressStart7())
                    .foregroundColor(.ink)
                    .lineLimit(1)
            }
        }
    }
}
