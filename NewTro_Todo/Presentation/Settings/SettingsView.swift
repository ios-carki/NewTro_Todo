import SwiftUI
import UIKit

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var statsVM: StatsViewModel
    let makeBackupLogVM: @MainActor () -> BackupLogViewModel

    @State private var openHelp: SettingsHelpKey?
    @State private var showTimeSheet = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                BackgroundSceneryView().ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, 14)
                        .padding(.top, 8)

                    ScrollView {
                        VStack(spacing: 10) {
                            mascotPanel
                            settingsPanel
                            tutorialPanel
                            notificationPanel
                            backupPanel
                            resetButton
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 10)
                        .padding(.bottom, 120)
                    }
                }

            }
            .sheet(isPresented: $viewModel.showExportPicker) {
                if let url = viewModel.pendingExportURL {
                    ExportDocumentPicker(url: url) { saved in
                        viewModel.handleExportResult(saved: saved)
                    }
                    .ignoresSafeArea()
                }
            }
            .sheet(isPresented: $viewModel.showImportPicker) {
                ImportDocumentPicker(
                    onPicked: { url in viewModel.handleImportPicked(url: url) },
                    onCancel: { viewModel.showImportPicker = false }
                )
                .ignoresSafeArea()
            }
            .overlayPreferenceValue(SettingsHelpAnchorKey.self) { anchors in
                helpOverlay(anchors: anchors)
            }
            .alert("데이터 초기화", isPresented: $viewModel.showResetConfirm) {
                Button("취소", role: .cancel) {}
                Button("초기화", role: .destructive) { viewModel.resetAllData() }
            } message: {
                Text("모든 할일과 메모가 삭제됩니다. 계속하시겠어요?")
            }
            .alert("알림 권한이 꺼져 있어요", isPresented: $viewModel.showPermissionDeniedAlert) {
                Button("취소", role: .cancel) {}
                Button("설정 열기") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("설정 앱에서 알림을 켜야 매일 알림을 받을 수 있어요.")
            }
            .onAppear { viewModel.refreshNotificationStateOnAppear() }
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
                            .font(.galBold11())
                            .foregroundColor(.shade)
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(LocalizedStringKey(currentCharInfo?.name ?? "핑코"))
                                .font(.galBold16())
                                .foregroundColor(.ink)
                            Spacer(minLength: 0)
                            Text(viewModel.appVersion)
                                .font(.pressStart10())
                                .foregroundColor(.sunDk)
                        }
                    }
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

    // MARK: - Settings Panel
    private var settingsPanel: some View {
        PixelPanel(bg: .white, padding: 0) {
            titleScreenRow
        }
    }

    private var titleScreenRow: some View {
        HStack(spacing: 8) {
            helpButton(for: .titleScreen)
            Text("타이틀 화면")
                .font(.galBold14())
                .foregroundColor(.ink)
            Spacer()
            PxSwitch(isOn: viewModel.welcomeOnLaunch) { viewModel.welcomeOnLaunch.toggle() }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white)
        .settingsHelpAnchor(SettingsHelpKey.titleScreen.rawValue)
    }

    // MARK: - Notification Panel
    private var notificationPanel: some View {
        PixelPanel(bg: .white, padding: 0) {
            VStack(spacing: 0) {
                notificationMasterRow

                if viewModel.notificationsEnabled {
                    Divider()
                        .background(Color.ink.opacity(0.2))
                        .padding(.horizontal, 14)
                    notificationTimeCell

                    if viewModel.isCustomNotificationTimes {
                        Divider()
                            .background(Color.ink.opacity(0.2))
                            .padding(.horizontal, 14)
                        resetToSystemRow
                    }
                }
            }
            .animation(.easeOut(duration: 0.2), value: viewModel.notificationsEnabled)
            .animation(.easeOut(duration: 0.2), value: viewModel.isCustomNotificationTimes)
        }
        .sheet(isPresented: $showTimeSheet) {
            NotificationTimePickerSheet(viewModel: viewModel)
        }
    }

    private var notificationMasterRow: some View {
        HStack(spacing: 8) {
            Text("알림")
                .font(.galBold14())
                .foregroundColor(.ink)
            Spacer()
            PxSwitch(isOn: viewModel.notificationsEnabled) {
                withAnimation(.easeOut(duration: 0.2)) {
                    viewModel.toggleNotifications()
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var notificationTimeCell: some View {
        Button {
            showTimeSheet = true
        } label: {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("아침 알림")
                        .font(.galBold14())
                        .foregroundColor(.ink)
                    Text("자정 임박 알림")
                        .font(.galBold14())
                        .foregroundColor(.ink)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Text(timeString(viewModel.effectiveMorningTime))
                        .font(.pressStart10())
                        .foregroundColor(.sunDk)
                    Text(timeString(viewModel.effectiveMidnightTime))
                        .font(.pressStart10())
                        .foregroundColor(.sunDk)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.shade.opacity(0.5))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func timeString(_ time: (hour: Int, minute: Int)) -> String {
        String(format: "%02d:%02d", time.hour, time.minute)
    }

    private var resetToSystemRow: some View {
        Button {
            viewModel.resetNotificationTimesToSystem()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 12))
                    .foregroundColor(.shade)
                    .frame(width: 20)
                Text("시스템 기본으로 되돌리기")
                    .font(.galBold14())
                    .foregroundColor(.ink)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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

    // MARK: - Backup Panel
    private var backupPanel: some View {
        PixelPanel(bg: .white, padding: 0) {
            VStack(spacing: 0) {
                backupRow
                Divider()
                    .background(Color.ink.opacity(0.2))
                    .padding(.horizontal, 14)
                backupLogRow
                Divider()
                    .background(Color.ink.opacity(0.2))
                    .padding(.horizontal, 14)
                restoreRow
            }
        }
    }

    private var backupLogRow: some View {
        NavigationLink {
            BackupLogView(viewModel: makeBackupLogVM())
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 14))
                    .foregroundColor(.shade)
                    .frame(width: 20)
                Text("데이터 백업 로그")
                    .font(.galBold14())
                    .foregroundColor(.ink)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.shade.opacity(0.5))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var backupRow: some View {
        Button {
            viewModel.startBackup()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "externaldrive.badge.timemachine")
                    .font(.system(size: 14))
                    .foregroundColor(.shade)
                    .frame(width: 20)
                VStack(alignment: .leading, spacing: 4) {
                    Text("데이터 백업")
                        .font(.galBold14())
                        .foregroundColor(.ink)
                    Text(backupMetaLine)
                        .font(.galBold10())
                        .foregroundColor(.shade)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.shade.opacity(0.5))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(viewModel.backupPhase.isActive || viewModel.restorePhase.isActive)
    }

    private var restoreRow: some View {
        Button {
            viewModel.startRestoreFlow()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "tray.and.arrow.down.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.shade)
                    .frame(width: 20)
                Text("데이터 불러오기")
                    .font(.galBold14())
                    .foregroundColor(.ink)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.shade.opacity(0.5))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(viewModel.backupPhase.isActive || viewModel.restorePhase.isActive)
    }

    private var backupMetaLine: String {
        guard let date = viewModel.lastBackupAt else {
            return "최근 백업 없음".localized()
        }
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let when = formatter.string(from: date)
        let template = "마지막 %@ · %d회".localized()
        return String(format: template, when, viewModel.backupCount)
    }

    // MARK: - Tutorial Panel
    private var tutorialPanel: some View {
        PixelPanel(bg: .white, padding: 0) {
            HStack(spacing: 8) {
                helpButton(for: .tutorialReplay)

                Button {
                    NotificationCenter.default.post(name: .replayTodoCoachmark, object: nil)
                } label: {
                    HStack {
                        Text("튜토리얼 다시 보기")
                            .font(.galBold14())
                            .foregroundColor(.ink)
                        Spacer()
                        Text("PLAY ▶")
                            .font(.pressStart9())
                            .foregroundColor(.sunDk)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white)
            .settingsHelpAnchor(SettingsHelpKey.tutorialReplay.rawValue)
        }
    }

    // MARK: - Inline Help

    private func helpButton(for key: SettingsHelpKey) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) { openHelp = key }
        } label: {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(.shade)
                .frame(width: 20, height: 20)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
    }

    @ViewBuilder
    private func helpOverlay(anchors: [String: Anchor<CGRect>]) -> some View {
        GeometryReader { geo in
            if let key = openHelp, let anchor = anchors[key.rawValue] {
                let rect = geo[anchor]
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .fill(Color.black.opacity(0.55))
                        .ignoresSafeArea()
                        .reverseMask {
                            Rectangle()
                                .frame(width: rect.width, height: rect.height)
                                .position(x: rect.midX, y: rect.midY)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.15)) { openHelp = nil }
                        }

                    helpCard(for: key)
                        .frame(width: rect.width)
                        .offset(x: rect.minX, y: rect.maxY + 8)
                }
                .transition(.opacity)
            }
        }
    }

    private func helpCard(for key: SettingsHelpKey) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(key.message)
                .font(.galBold14())
                .foregroundColor(.ink)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Spacer()
                Button {
                    withAnimation(.easeOut(duration: 0.15)) { openHelp = nil }
                } label: {
                    Text("확인")
                        .font(.galBold14())
                        .foregroundColor(.ink)
                        .padding(.horizontal, 16)
                        .frame(height: 32)
                        .background(Color.peach)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(12)
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
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

// MARK: - Inline Help Anchor

enum SettingsHelpKey: String {
    case titleScreen    = "title_screen"
    case tutorialReplay = "tutorial_replay"

    var message: LocalizedStringKey {
        switch self {
        case .titleScreen:    return "ON 시 앱 실행마다 타이틀 화면이 표시됩니다."
        case .tutorialReplay: return "Todo 화면에 대한 설명을 다시 볼 수 있어요."
        }
    }
}

struct SettingsHelpAnchorKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

extension View {
    fileprivate func settingsHelpAnchor(_ id: String) -> some View {
        anchorPreference(key: SettingsHelpAnchorKey.self, value: .bounds) { [id: $0] }
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

