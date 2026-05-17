import SwiftUI
import UIKit

// UIDatePicker SwiftUI 래퍼. 모드에 따라 날짜 전용 / 날짜+시각 wheel을 렌더링.
// minuteInterval은 mode == .dateAndTime 일 때만 의미를 가진다.
struct PixelDateWheel: View {
    enum Mode {
        case date           // 연월일 + 요일 콤보 wheel
        case dateAndTime    // 위 + 오전/오후 + 시 + 분(분단위는 minuteInterval로 스냅)
    }

    @Binding var date: Date
    var mode: Mode = .date
    var minimumDate: Date? = nil
    var maximumDate: Date? = nil
    var minuteInterval: Int = 5

    var body: some View {
        DatePickerRepresentable(
            date: $date,
            mode: mode,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            minuteInterval: minuteInterval
        )
        .frame(height: mode == .date ? 160 : 200)
        .frame(maxWidth: .infinity)
        .clipped()
        .padding(.vertical, 4)
        .background(Color.tile)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
    }
}

private struct DatePickerRepresentable: UIViewRepresentable {
    @Binding var date: Date
    let mode: PixelDateWheel.Mode
    let minimumDate: Date?
    let maximumDate: Date?
    let minuteInterval: Int

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UIDatePicker {
        let dp = UIDatePicker()
        dp.preferredDatePickerStyle = .wheels
        dp.datePickerMode = (mode == .date) ? .date : .dateAndTime
        if mode == .dateAndTime { dp.minuteInterval = minuteInterval }
        dp.minimumDate = minimumDate
        dp.maximumDate = maximumDate
        dp.locale = Locale.current
        dp.setDate(date, animated: false)
        dp.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
        return dp
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        context.coordinator.parent = self
        if uiView.minimumDate != minimumDate { uiView.minimumDate = minimumDate }
        if uiView.maximumDate != maximumDate { uiView.maximumDate = maximumDate }
        // wheel이 끌리는 도중에 setDate를 호출하면 사용자 입력을 가로채므로
        // 외부에서 명시적으로 date가 바뀐 경우(현재 wheel값과 다를 때)만 동기화.
        if abs(uiView.date.timeIntervalSince(date)) > 1 {
            uiView.setDate(date, animated: false)
        }
    }

    final class Coordinator: NSObject {
        var parent: DatePickerRepresentable
        init(_ parent: DatePickerRepresentable) { self.parent = parent }

        @objc func changed(_ sender: UIDatePicker) {
            parent.date = sender.date
        }
    }
}
