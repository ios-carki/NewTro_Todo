import SwiftUI
import UIKit

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var statsVM: StatsViewModel
    let makeBackupLogVM: @MainActor () -> BackupLogViewModel

    @EnvironmentObject private var popupCenter: PopupCenter
    @State private var openHelp: SettingsHelpKey?
    @State private var showTimeSheet = false
    @State private var showMascotPicker = false
    @State private var showBackupLog = false

    var body: some View {
        ZStack(alignment: .bottom) {
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
        .overlay(alignment: .bottom) { FloatingTabBar() }
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
        .fullScreenCover(isPresented: $showMascotPicker) {
            MascotPickerCover(settingsVM: viewModel, statsVM: statsVM)
        }
        .fullScreenCover(isPresented: $showBackupLog) {
            BackupLogCover(makeVM: makeBackupLogVM)
        }
        .overlayPreferenceValue(SettingsHelpAnchorKey.self) { anchors in
            helpOverlay(anchors: anchors)
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
        .onAppear {
            viewModel.refreshNotificationStateOnAppear()
            viewModel.refreshWalletBalance()
        }
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
                        HStack(spacing: 6) {
                            Text("내 마스코트")
                                .font(.galBold11())
                                .foregroundColor(.shade)
                            Spacer(minLength: 0)
                            walletCoinChip
                        }
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

                Button {
                    showMascotPicker = true
                } label: {
                    settingRowNavigation(label: "마스코트 변경", icon: "person.fill")
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // 마스코트 섹션 우상단의 지갑 잔액 칩. 메인 HUD 와 동일한 coin pixel + ×count 포맷.
    // 클릭 액션 없음 — 단순 표시.
    private var walletCoinChip: some View {
        HStack(spacing: 4) {
            PixelArtView(grid: PixelArtAssets.coinGrid, palette: PixelArtAssets.coinPalette, scale: 1.6)
            Text("×\(viewModel.walletBalance)")
                .font(.pressStart10())
                .foregroundColor(.sun)
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
                handleNotificationSwitchTap()
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    // ON 일 때 탭 → 확인 팝업, 확인 누른 경우에만 실제 OFF (취소/dim 탭은 ON 유지).
    // OFF 일 때 탭 → 권한 확인 후 ON. 권한 거부 상태면 기존 alert 로 설정 앱 유도.
    private func handleNotificationSwitchTap() {
        if viewModel.notificationsEnabled {
            presentDisableNotificationsConfirm()
        } else {
            withAnimation(.easeOut(duration: 0.2)) {
                viewModel.requestEnableNotifications()
            }
        }
    }

    // 알림 끄기 확정 팝업.
    // dim 탭으로도 닫히지만 (`dismissOnBackgroundTap: true`), 닫혀도 VM 상태는 건드리지
    // 않으므로 스위치는 ON 으로 유지됨. 확인 버튼만 실제 OFF + 스케줄 cancel 트리거.
    private func presentDisableNotificationsConfirm() {
        popupCenter.present(dismissOnBackgroundTap: true) {
            DisableNotificationsConfirmCard(
                onCancel: { popupCenter.dismiss() },
                onConfirm: {
                    popupCenter.dismiss()
                    withAnimation(.easeOut(duration: 0.2)) {
                        viewModel.disableNotifications()
                    }
                }
            )
        }
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
        Button {
            showBackupLog = true
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
        Button { presentResetConfirm() } label: {
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

    // 파괴적 액션이라 배경 탭 dismiss 막음. 취소/초기화 명시 선택만 허용.
    private func presentResetConfirm() {
        popupCenter.present(dismissOnBackgroundTap: false) {
            ResetConfirmCard(
                onCancel: { popupCenter.dismiss() },
                onConfirm: {
                    popupCenter.dismiss()
                    viewModel.resetAllData()
                }
            )
        }
    }
}

// MARK: - Disable Notifications Confirm Card
//
// 알림 OFF 액션이 파괴적(예약된 모든 알림 cancel)임을 명시. 디자인은 ResetConfirmCard 와
// 동일한 panel + ink stroke + drop shadow 패턴. 확인 버튼 톤은 peachDk — 알림 OFF 는
// 데이터 파괴가 아니므로 pixelRed(파괴) 와 구분.
private struct DisableNotificationsConfirmCard: View {
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text("알림 끄기")
                .font(.galBold16())
                .foregroundColor(.ink)

            Rectangle()
                .fill(Color.ink.opacity(0.25))
                .frame(height: 1)
                .padding(.horizontal, 4)

            Text("할 일 알림을 비롯한 모든 알림이 더 이상 표시되지 않아요.\n그래도 끄시겠어요?")
                .font(.galBold13())
                .foregroundColor(.shade)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Button(action: onCancel) {
                    Text("취소")
                        .font(.galBold13())
                        .foregroundColor(.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.cream)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
                }
                .buttonStyle(.plain)

                Button(action: onConfirm) {
                    Text("끄기")
                        .font(.galBold13())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.peachDk)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
    }
}

// MARK: - Reset Confirm Card
private struct ResetConfirmCard: View {
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text("데이터 초기화")
                .font(.galBold16())
                .foregroundColor(.ink)

            Rectangle()
                .fill(Color.ink.opacity(0.25))
                .frame(height: 1)
                .padding(.horizontal, 4)

            Text("모든 할일과 메모가 삭제됩니다.\n계속하시겠어요?")
                .font(.galBold13())
                .foregroundColor(.shade)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Button(action: onCancel) {
                    Text("취소")
                        .font(.galBold13())
                        .foregroundColor(.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.cream)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
                }
                .buttonStyle(.plain)

                Button(action: onConfirm) {
                    Text("초기화")
                        .font(.galBold13())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.pixelRed)
                        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
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

