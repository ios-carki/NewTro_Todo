import SwiftUI

// TodoAddOverlayContent 의 알림 row에서 push 되는 알림 시각 선택 화면.
// 외부 binding은 PxCheckIcon 탭 시점에만 갱신 — 사용자가 wheel을 만지작거리다 cancel(닫기)하면 원복.
struct ReminderDatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var reminderDate: Date

    @State private var tempDate: Date

    init(reminderDate: Binding<Date>) {
        self._reminderDate = reminderDate
        self._tempDate = State(initialValue: reminderDate.wrappedValue)
    }

    var body: some View {
        ZStack {
            Color.panel.ignoresSafeArea()

            VStack(spacing: 14) {
                topBar
                todayChipRow
                PixelDateWheel(
                    date: $tempDate,
                    mode: .dateAndTime,
                    minimumDate: Date(),
                    minuteInterval: 5
                )
                .padding(.horizontal, 16)
                Spacer(minLength: 0)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    // MARK: - Top Bar
    private var topBar: some View {
        ZStack {
            HStack {
                PxXIcon { dismiss() }
                Spacer()
                PxCheckIcon {
                    reminderDate = tempDate
                    dismiss()
                }
            }

            Text("알림 시각")
                .font(.galBold17())
                .foregroundColor(.ink)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: - "오늘" 리셋 칩 — 현재 wheel을 오늘 + 다음 정각으로 되돌림.
    private var todayChipRow: some View {
        HStack {
            Spacer()
            Button {
                tempDate = Self.defaultReminderDate()
            } label: {
                Text("오늘")
                    .font(.pressStart9())
                    .foregroundColor(.ink)
                    .padding(.horizontal, 14)
                    .frame(height: 30)
                    .background(Color.cream)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
                    .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .padding(.horizontal, 16)
    }

    // 오늘 칩 / 신규 todo 기본값 모두 동일 정책: 현재 시각 +1시간을 5분 단위로 올림.
    static func defaultReminderDate() -> Date {
        let cal = Calendar.current
        let plusHour = Date().addingTimeInterval(3600)
        var comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: plusHour)
        let minute = comps.minute ?? 0
        let rounded = ((minute + 4) / 5) * 5
        if rounded >= 60 {
            comps.hour = (comps.hour ?? 0) + 1
            comps.minute = 0
        } else {
            comps.minute = rounded
        }
        return cal.date(from: comps) ?? plusHour
    }
}
