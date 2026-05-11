import SwiftUI

struct NotificationTimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var viewModel: SettingsViewModel

    @State private var morningHour: Int
    @State private var morningMinute: Int
    @State private var midnightHour: Int
    @State private var midnightMinute: Int

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        let m = viewModel.effectiveMorningTime
        let n = viewModel.effectiveMidnightTime
        _morningHour   = State(initialValue: m.hour)
        _morningMinute = State(initialValue: m.minute)
        _midnightHour   = State(initialValue: n.hour)
        _midnightMinute = State(initialValue: n.minute)
    }

    var body: some View {
        ZStack {
            Color.sky.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                content
                Spacer(minLength: 0)
            }
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        ZStack {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.ink)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    viewModel.saveCustomNotificationTimes(
                        morning:  (morningHour,  morningMinute),
                        midnight: (midnightHour, midnightMinute)
                    )
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.ink)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            Text("알림")
                .font(.galBold17())
                .foregroundColor(.ink)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: - Content
    private var content: some View {
        VStack(spacing: 18) {
            timeSection(
                titleKey: "아침 알림",
                hour:   $morningHour,
                minute: $morningMinute
            )
            timeSection(
                titleKey: "자정 임박 알림",
                hour:   $midnightHour,
                minute: $midnightMinute
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func timeSection(
        titleKey: LocalizedStringKey,
        hour: Binding<Int>,
        minute: Binding<Int>
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(titleKey)
                .font(.galBold16())
                .foregroundColor(.ink)
            PixelTimeWheel(hour: hour, minute: minute)
        }
    }
}
