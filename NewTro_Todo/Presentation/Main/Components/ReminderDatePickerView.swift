import SwiftUI

// TodoAddOverlayContent 의 알림 row에서 sheet 로 present 되는 알림 시각 선택 화면.
// 알림 row 에 토글이 없어 ON/OFF 트랜지션이 이 picker 에서 일어남:
//  - "선택" → reminderDate 갱신 + hasReminder = true
//  - "취소" → 원복
//  - "알림 끄기" → hasReminder = false (현재 ON 상태로 진입한 경우에만 노출)
struct ReminderDatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var reminderDate: Date
    @Binding var hasReminder: Bool

    @State private var tempDate: Date
    // 시트 진입 시점의 hasReminder 를 캡쳐. 켜진 상태로 들어왔을 때만 "끄기" 버튼 노출.
    @State private var wasInitiallyOn: Bool

    init(reminderDate: Binding<Date>, hasReminder: Binding<Bool>) {
        self._reminderDate = reminderDate
        self._hasReminder = hasReminder
        self._tempDate = State(initialValue: reminderDate.wrappedValue)
        self._wasInitiallyOn = State(initialValue: hasReminder.wrappedValue)
    }

    var body: some View {
        ZStack {
            Color.panel.ignoresSafeArea()

            VStack(spacing: 14) {
                Text("알림 시각")
                    .font(.galBold17())
                    .foregroundColor(.ink)
                    .padding(.top, 16)

                liveHeaderRow
                    .padding(.horizontal, 16)

                PixelDateWheel(
                    date: $tempDate,
                    mode: .dateAndTime,
                    minimumDate: Date(),
                    minuteInterval: 5
                )
                .padding(.horizontal, 16)

                Spacer(minLength: 0)

                bottomButtons
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
    }

    // MARK: - Live Header (좌: 현재 선택값 / 우: "오늘" reset chip)

    private var liveHeaderRow: some View {
        HStack(spacing: 10) {
            Text(formattedHeader(tempDate))
                .font(.galBold14())
                .foregroundColor(.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)

            todayChip
        }
    }

    private var todayChip: some View {
        Button {
            tempDate = Self.defaultReminderDate()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 10, weight: .bold))
                Text("오늘")
                    .font(.galBold11())
            }
            .foregroundColor(.ink)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.cream)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        HStack(spacing: 10) {
            if wasInitiallyOn {
                Button {
                    hasReminder = false
                    dismiss()
                } label: {
                    Text("끄기")
                        .font(.galBold13())
                        .foregroundColor(.redDk)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.redLt.opacity(0.4))
                        .overlay(Rectangle().stroke(Color.redDk, lineWidth: 2))
                }
            }
            Button { dismiss() } label: {
                Text("취소")
                    .font(.galBold13())
                    .foregroundColor(.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.panel)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            }
            Button {
                reminderDate = tempDate
                hasReminder = true
                dismiss()
            } label: {
                Text("선택")
                    .font(.galBold13())
                    .foregroundColor(.cream)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.peachDk)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
            }
        }
    }

    // MARK: - Helpers

    // "2026.5.17 (월) 오후 6:00" 포맷. 요일은 시스템 로케일 단축형 (DateFormatter EEE).
    private func formattedHeader(_ d: Date) -> String {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: d)
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale.current
        weekdayFormatter.dateFormat = "EEE"
        let weekday = weekdayFormatter.string(from: d)

        let h24 = comps.hour ?? 0
        let h12: Int = {
            if h24 == 0 { return 12 }
            if h24 == 12 { return 12 }
            return h24 > 12 ? h24 - 12 : h24
        }()
        let period = h24 < 12 ? "오전" : "오후"

        return String(
            format: "%d.%d.%d (%@) %@ %d:%02d",
            comps.year ?? 0, comps.month ?? 0, comps.day ?? 0,
            weekday, period, h12, comps.minute ?? 0
        )
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
