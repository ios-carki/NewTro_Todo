import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var statsVM: StatsViewModel

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Color.sky.ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, 14)
                        .padding(.top, 8)

                    ScrollView {
                        VStack(spacing: 10) {
                            mascotPanel
                            achievementPanel
                            settingsPanel
                            tutorialPanel
                            aboutPanel
                            resetButton
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 10)
                        .padding(.bottom, 120)
                    }
                }
            }
            .alert("데이터 초기화", isPresented: $viewModel.showResetConfirm) {
                Button("취소", role: .cancel) {}
                Button("초기화", role: .destructive) { viewModel.resetAllData() }
            } message: {
                Text("모든 할일과 메모가 삭제됩니다. 계속하시겠어요?")
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Text("설정")
                .font(.galBold22())
                .foregroundColor(.ink)
            Spacer()
        }
        .padding(.vertical, 6)
    }

    // MARK: - Mascot Panel
    private var mascotPanel: some View {
        PixelPanel(bg: .cream, padding: 0) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    currentMascotPreview
                    VStack(alignment: .leading, spacing: 4) {
                        Text("내 마스코트")
                            .font(.pressStart9())
                            .foregroundColor(.shade)
                        Text(LocalizedStringKey(currentCharInfo?.name ?? "핑코"))
                            .font(.galBold16())
                            .foregroundColor(.ink)
                        Text("LV.\(statsVM.stats.level) · \(statsVM.levelTitle)")
                            .font(.pressStart7())
                            .foregroundColor(.sun)
                    }
                    Spacer()
                }
                .padding(14)

                Divider().background(Color.ink.opacity(0.2)).padding(.horizontal, 14)

                NavigationLink {
                    MascotPickerView(settingsVM: viewModel, statsVM: statsVM)
                } label: {
                    settingRowNavigation(label: "마스코트 변경", icon: "person.fill")
                }
            }
        }
    }

    private var currentMascotPreview: some View {
        ZStack {
            Color.panel
                .frame(width: 56, height: 56)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            if let info = currentCharInfo {
                PixelArtView(
                    grid: PixelArtAssets.characterGrid(type: info.gridType),
                    palette: info.palette,
                    scale: 4.5
                )
            }
        }
    }

    private var currentCharInfo: FriendCharInfo? {
        CharacterData.all.first { $0.id == viewModel.selectedCharacterId }
    }

    // MARK: - Achievement Panel
    private var achievementPanel: some View {
        PixelPanel(bg: .white, padding: 0) {
            VStack(spacing: 0) {
                NavigationLink {
                    AchievementView(statsVM: statsVM)
                } label: {
                    settingRowNavigation(label: "업적 & 도전과제", icon: "trophy.fill")
                }
            }
        }
    }

    // MARK: - Settings Panel
    private var settingsPanel: some View {
        PixelPanel(bg: .white, padding: 0) {
            VStack(spacing: 0) {
                settingRow(label: "테마") {
                    SegToggle(
                        options: [("peach", "복숭아"), ("pink", "핑크"), ("sun", "햇살")],
                        selected: viewModel.theme
                    ) { viewModel.theme = $0 }
                }
                Divider().background(Color.ink.opacity(0.2)).padding(.horizontal, 14)

                settingRow(label: "스캔라인") {
                    PxSwitch(isOn: viewModel.scanlineOn) { viewModel.scanlineOn.toggle() }
                }
                Divider().background(Color.ink.opacity(0.2)).padding(.horizontal, 14)

                settingRow(label: "마스코트 화면") {
                    PxSwitch(isOn: viewModel.welcomeOnLaunch) { viewModel.welcomeOnLaunch.toggle() }
                }
            }
        }
    }

    private func settingRow<C: View>(label: LocalizedStringKey, @ViewBuilder content: () -> C) -> some View {
        HStack {
            Text(label)
                .font(.galBold14())
                .foregroundColor(.ink)
            Spacer()
            content()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private func settingRowNavigation(label: LocalizedStringKey, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.shade)
                .frame(width: 20)
            Text(label)
                .font(.galBold14())
                .foregroundColor(.ink)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.shade.opacity(0.5))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    // MARK: - Tutorial Panel
    private var tutorialPanel: some View {
        PixelPanel(bg: .white, padding: 0) {
            Button {
                NotificationCenter.default.post(name: .replayTodoCoachmark, object: nil)
            } label: {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.shade)
                        .frame(width: 20)
                    Text("튜토리얼 다시 보기")
                        .font(.galBold14())
                        .foregroundColor(.ink)
                    Spacer()
                    Text("PLAY ▶")
                        .font(.pressStart7())
                        .foregroundColor(.sun)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - About Panel
    private var aboutPanel: some View {
        PixelPanel(bg: .cream, padding: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("소개")
                    .font(.pressStart9())
                    .foregroundColor(.shade)

                HStack {
                    Text("New-Tro ToDo!")
                        .font(.pressStart14())
                        .foregroundColor(.ink)
                    Spacer()
                    Text("v\(viewModel.appVersion)")
                        .font(.pressStart9())
                        .foregroundColor(.shade)
                }

                HStack(spacing: 14) {
                    MascotBobView(info: currentCharInfo ?? CharacterData.all[0])

                    VStack(alignment: .leading, spacing: 4) {
                        Text("레트로 감성 할 일 관리")
                            .font(.pressStart9())
                            .foregroundColor(.shade)
                        Text("최고의 투두앱 ♡")
                            .font(.galBold16())
                            .foregroundColor(.pinkDk)
                        Text("마스코트 화면 ON 시\n앱 실행마다 표시됩니다")
                            .font(.pressStart7())
                            .foregroundColor(.shade)
                            .padding(.top, 2)
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Reset Button
    private var resetButton: some View {
        Button { viewModel.confirmReset() } label: {
            Text("모든 데이터 초기화")
                .font(.galBold14())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.pixelRed)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
        }
    }
}

// MARK: - MascotBobView
private struct MascotBobView: View {
    let info: FriendCharInfo
    @State private var bobY: CGFloat = 0

    var body: some View {
        PixelArtView(
            grid: PixelArtAssets.characterGrid(type: info.gridType),
            palette: info.palette,
            scale: 4
        )
        .offset(y: bobY)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.45).repeatForever(autoreverses: true)) {
                    bobY = -4
                }
            }
        }
    }
}

// MARK: - PxSwitch
struct PxSwitch: View {
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Rectangle()
                    .fill(isOn ? Color.grass : Color.shade.opacity(0.25))
                    .frame(width: 50, height: 24)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))

                Rectangle()
                    .fill(Color.cream)
                    .frame(width: 20, height: 20)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    .padding(2)
            }
            .animation(.linear(duration: 0.08), value: isOn)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SegToggle
struct SegToggle: View {
    let options: [(String, LocalizedStringKey)]
    let selected: String
    let onChange: (String) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.0) { value, label in
                Button { onChange(value) } label: {
                    Text(label)
                        .font(.pressStart7())
                        .foregroundColor(.ink)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(selected == value ? Color.sun : Color.white)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                }
            }
        }
    }
}
