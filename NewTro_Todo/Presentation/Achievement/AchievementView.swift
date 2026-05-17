import SwiftUI

struct AchievementView: View {
    @ObservedObject var statsVM: StatsViewModel
    @State private var claimedFlash: String? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.sky.ignoresSafeArea()

            ScrollView {
                challengesContent
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
            }
        }
        .navigationTitle(Text("도전과제"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { statsVM.loadStats() }
    }

    // MARK: - Challenges
    private var challengesContent: some View {
        VStack(spacing: 20) {
            challengeSection(
                title: "오늘의 도전",
                subtitle: todayChallengeSubtitle,
                challenges: ChallengeData.daily
            )
            challengeSection(
                title: "연속 도전",
                subtitle: "연속 기록: %d일".localized(with: statsVM.stats.currentStreak),
                challenges: ChallengeData.streak
            )
            challengeSection(
                title: "누적 도전",
                subtitle: "누적 완료: %d개".localized(with: statsVM.stats.totalCompleted),
                challenges: ChallengeData.cumulative
            )
        }
    }

    private var todayChallengeSubtitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMd")
        return formatter.string(from: Date())
    }

    private func challengeSection(title: LocalizedStringKey, subtitle: String, challenges: [ChallengeDefinition]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom) {
                Text(title)
                    .font(.pressStart9())
                    .foregroundColor(.ink)
                Spacer()
                Text(subtitle)
                    .font(.pressStart9())
                    .foregroundColor(.shade)
            }

            VStack(spacing: 8) {
                ForEach(challenges) { challenge in
                    ChallengeCard(
                        challenge: challenge,
                        stats: statsVM.stats,
                        claimedFlash: claimedFlash
                    ) { claimId, points in
                        claimedFlash = claimId
                        statsVM.claimChallenge(challengeId: claimId, points: points)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            claimedFlash = nil
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Challenge Card
private struct ChallengeCard: View {
    let challenge: ChallengeDefinition
    let stats: StatsEntity
    let claimedFlash: String?
    let onClaim: (String, Int) -> Void

    private var claimId: String { challenge.claimId() }
    private var isClaimed: Bool { challenge.isClaimed(stats: stats) }
    private var isCompleted: Bool { challenge.isCompleted(stats: stats) }
    private var progress: Int { challenge.progress(stats: stats) }
    private var ratio: Double { Double(progress) / Double(challenge.targetValue) }
    private var isFlashing: Bool { claimedFlash == claimId }

    var body: some View {
        PixelPanel(bg: cardBg, padding: 10) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: challenge.sfSymbol)
                        .font(.system(size: 14))
                        .foregroundColor(isClaimed ? .shade : challenge.accentColor)
                    Text(LocalizedStringKey(challenge.title))
                        .font(.galBold14())
                        .foregroundColor(isClaimed ? .shade : .ink)
                    Spacer()
                    if let charId = challenge.rewardCharacterId,
                       let charInfo = CharacterData.all.first(where: { $0.id == charId }) {
                        rewardCharacterBadge(charInfo)
                    }
                }

                Text(LocalizedStringKey(challenge.description))
                    .font(.pressStart9())
                    .foregroundColor(isClaimed ? .shade.opacity(0.6) : .shade)

                if challenge.targetValue > 1 {
                    progressBar
                }

                HStack {
                    Text("+\(challenge.rewardPoints)pt")
                        .font(.pressStart9())
                        .foregroundColor(isClaimed ? .shade : .sun)
                    Spacer()
                    stateView
                }
            }
        }
        .scaleEffect(isFlashing ? 1.03 : 1.0)
        .animation(.spring(response: 0.3), value: isFlashing)
    }

    private var cardBg: Color {
        if isClaimed { return Color.panel.opacity(0.5) }
        if isCompleted { return Color.sun.opacity(0.15) }
        return Color.panel
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle().fill(Color.ink.opacity(0.08))
                Rectangle()
                    .fill(isClaimed ? Color.shade.opacity(0.3) : challenge.accentColor)
                    .frame(width: geo.size.width * min(ratio, 1.0))
                    .animation(.easeInOut(duration: 0.3), value: ratio)
                Text("\(progress)/\(challenge.targetValue)")
                    .font(.pressStart9())
                    .foregroundColor(.ink)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 16)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
    }

    @ViewBuilder
    private var stateView: some View {
        if isClaimed {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.done)
                Text("완료")
                    .font(.pressStart9())
                    .foregroundColor(.done)
            }
        } else if isCompleted {
            Button {
                onClaim(claimId, challenge.rewardPoints)
            } label: {
                Text("수령하기")
                    .font(.pressStart9())
                    .foregroundColor(.cream)
                    .padding(.horizontal, 10)
                    .frame(height: 26)
                    .background(Color.grass)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
            }
        } else {
            Text("진행 중")
                .font(.pressStart9())
                .foregroundColor(.shade.opacity(0.6))
        }
    }

    private func rewardCharacterBadge(_ info: FriendCharInfo) -> some View {
        let isUnlocked = stats.unlockedCharacterIds.contains(info.id)
        return ZStack {
            (isUnlocked ? Color.panel : Color.ink.opacity(0.06))
                .frame(width: 28, height: 28)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
            if isUnlocked {
                PixelArtView(
                    grid: PixelArtAssets.characterGrid(type: info.gridType),
                    palette: info.palette,
                    scale: 2.4
                )
            } else {
                Text("?")
                    .font(.pressStart9())
                    .foregroundColor(.shade.opacity(0.5))
            }
        }
    }
}
