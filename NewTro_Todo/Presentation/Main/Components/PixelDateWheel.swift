import SwiftUI
import UIKit

// 픽셀 톤 날짜/날짜+시각 wheel. UIDatePicker 는 폰트 커스터마이즈가 사실상 불가능해서
// PixelTimeWheel 과 같은 UIPickerView 기반으로 직접 구현 — 라벨에 Galmuri11-Bold 적용.
struct PixelDateWheel: View {
    enum Mode {
        case date           // 년 | 월 | 일
        case dateAndTime    // 년 | 월 | 일 | 오전/오후 | 시 | 분
    }

    @Binding var date: Date
    var mode: Mode = .date
    var minimumDate: Date? = nil
    var maximumDate: Date? = nil
    var minuteInterval: Int = 5

    private let rowHeight: CGFloat = 32
    private var height: CGFloat { rowHeight * 5 }    // 5행 노출

    var body: some View {
        PixelDateWheelRepresentable(
            date: $date,
            mode: mode,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            minuteInterval: minuteInterval,
            rowHeight: rowHeight
        )
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipped()
        .padding(.vertical, 4)
        .background(Color.tile)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
    }
}

private struct PixelDateWheelRepresentable: UIViewRepresentable {
    @Binding var date: Date
    let mode: PixelDateWheel.Mode
    let minimumDate: Date?
    let maximumDate: Date?
    let minuteInterval: Int
    let rowHeight: CGFloat

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UIPickerView {
        let pv = UIPickerView()
        pv.dataSource = context.coordinator
        pv.delegate   = context.coordinator
        pv.backgroundColor = .clear
        pv.clipsToBounds = true
        context.coordinator.applySelection(on: pv, animated: false)
        return pv
    }

    func updateUIView(_ uiView: UIPickerView, context: Context) {
        context.coordinator.parent = self
        // wheel 끌리는 도중 외부 동기화가 입력을 가로채지 않도록,
        // 외부 date 와 현재 wheel 결과가 크게 다를 때만 재반영.
        context.coordinator.applySelectionIfChanged(on: uiView)
    }

    // monthYear: 년 컬럼 없는 dateAndTime 모드 전용 — 1970.1 ~ 2100.12 까지 (yearRange.count * 12) 행을
    // 평탄화해 한 컬럼에 담음. 표시는 월 숫자만, 내부 인덱스에서 년도가 자동 도출됨.
    enum Column { case year, month, day, ampm, hour12, minute, monthYear }

    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: PixelDateWheelRepresentable

        // 년 범위. 캘린더 일반 사용 범위로 충분.
        private let yearRange: ClosedRange<Int> = 1970...2100

        init(_ parent: PixelDateWheelRepresentable) { self.parent = parent }

        private var columns: [Column] {
            switch parent.mode {
            case .date:        return [.year, .month, .day]
            case .dateAndTime: return [.monthYear, .day, .ampm, .hour12, .minute]
            }
        }

        // MARK: - DataSource

        func numberOfComponents(in pickerView: UIPickerView) -> Int { columns.count }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch columns[component] {
            case .year:      return yearRange.count
            case .month:     return 12
            case .monthYear: return yearRange.count * 12
            case .day:       return daysIn(year: currentYear(picker: pickerView),
                                           month: currentMonth(picker: pickerView))
            case .ampm:      return 2
            case .hour12:    return 12
            case .minute:    return max(1, 60 / parent.minuteInterval)
            }
        }

        // MARK: - Delegate (layout / view)

        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            parent.rowHeight
        }

        // widthForComponent 를 직접 지정하면 UIPickerView 의 selection indicator 내부 inset 과 어긋나
        // 마지막 컬럼이 indicator 영역 밖으로 밀려나가는 문제가 있어 균등 분배(기본)에 맡김.

func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            label.font = UIFont(name: "Galmuri11-Bold", size: 18) ?? .boldSystemFont(ofSize: 18)
            label.textColor = .inkC
            label.textAlignment = .center

            switch columns[component] {
            case .year:   label.text = "\(yearRange.lowerBound + row)" + NSLocalizedString("년", comment: "")
            case .month:  label.text = "\(row + 1)" + NSLocalizedString("월", comment: "")
            case .monthYear:
                // 표시는 월만. 년도는 내부 인덱스에서 도출.
                let month = (row % 12) + 1
                label.text = "\(month)" + NSLocalizedString("월", comment: "")
            case .day:    label.text = "\(row + 1)" + NSLocalizedString("일", comment: "")
            case .ampm:
                label.text = row == 0
                    ? NSLocalizedString("오전", comment: "")
                    : NSLocalizedString("오후", comment: "")
            case .hour12: label.text = String(format: "%d", row + 1)
            case .minute: label.text = String(format: "%02d", row * parent.minuteInterval)
            }
            return label
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            // year / month / monthYear 변경 시 day 행 수가 달라질 수 있어 reload + 초과분 클램프.
            let col = columns[component]
            if (col == .year || col == .month || col == .monthYear),
               let dayCol = columns.firstIndex(of: .day) {
                pickerView.reloadComponent(dayCol)
                let maxDay = daysIn(year: currentYear(picker: pickerView),
                                    month: currentMonth(picker: pickerView))
                if pickerView.selectedRow(inComponent: dayCol) > maxDay - 1 {
                    pickerView.selectRow(maxDay - 1, inComponent: dayCol, animated: true)
                }
            }
            commit(picker: pickerView)
        }

        // MARK: - 선택 적용

        func applySelection(on pv: UIPickerView, animated: Bool) {
            let cal = Calendar.current
            let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: parent.date)
            let y = comps.year ?? Calendar.current.component(.year, from: Date())
            let m = comps.month ?? 1
            let d = comps.day ?? 1
            let h24 = comps.hour ?? 0
            let mi = comps.minute ?? 0

            for (i, col) in columns.enumerated() {
                let row = self.row(for: col, year: y, month: m, day: d, hour24: h24, minute: mi)
                if pv.selectedRow(inComponent: i) != row {
                    pv.selectRow(row, inComponent: i, animated: animated)
                }
            }
        }

        func applySelectionIfChanged(on pv: UIPickerView) {
            guard let current = currentDate(picker: pv) else {
                applySelection(on: pv, animated: false); return
            }
            // 사용자가 wheel 끌어 발생한 자체 변경은 무시. 외부에서 명시적 변경이 온 경우만 동기화.
            if abs(current.timeIntervalSince(parent.date)) > 30 {
                applySelection(on: pv, animated: false)
            }
        }

        private func row(for col: Column, year: Int, month: Int, day: Int, hour24: Int, minute: Int) -> Int {
            switch col {
            case .year:   return max(0, min(yearRange.count - 1, year - yearRange.lowerBound))
            case .month:  return max(0, min(11, month - 1))
            case .monthYear:
                let clampedYear = max(yearRange.lowerBound, min(yearRange.upperBound, year))
                let idx = (clampedYear - yearRange.lowerBound) * 12 + (month - 1)
                return max(0, min(yearRange.count * 12 - 1, idx))
            case .day:    return max(0, min(30, day - 1))
            case .ampm:   return hour24 < 12 ? 0 : 1
            case .hour12:
                let h12: Int
                if hour24 == 0 { h12 = 12 }
                else if hour24 == 12 { h12 = 12 }
                else if hour24 < 12 { h12 = hour24 }
                else { h12 = hour24 - 12 }
                return h12 - 1
            case .minute:
                let step = max(1, parent.minuteInterval)
                return max(0, min((60 / step) - 1, minute / step))
            }
        }

        private func commit(picker: UIPickerView) {
            guard let newDate = currentDate(picker: picker) else { return }
            var clamped = newDate
            if let min = parent.minimumDate, clamped < min {
                clamped = min
                applySelection(on: picker, animated: true)
            }
            if let max = parent.maximumDate, clamped > max {
                clamped = max
                applySelection(on: picker, animated: true)
            }
            parent.date = clamped
        }

        private func currentDate(picker: UIPickerView) -> Date? {
            var comps = DateComponents()
            comps.year  = currentYear(picker: picker)
            comps.month = currentMonth(picker: picker)
            comps.day   = currentDay(picker: picker)

            if parent.mode == .dateAndTime,
               let ampmCol = columns.firstIndex(of: .ampm),
               let hCol    = columns.firstIndex(of: .hour12),
               let miCol   = columns.firstIndex(of: .minute) {
                let ampm = picker.selectedRow(inComponent: ampmCol)
                let h12  = picker.selectedRow(inComponent: hCol) + 1
                let mi   = picker.selectedRow(inComponent: miCol) * max(1, parent.minuteInterval)
                let h24: Int
                if ampm == 0 { h24 = (h12 == 12) ? 0  : h12 }
                else         { h24 = (h12 == 12) ? 12 : h12 + 12 }
                comps.hour = h24
                comps.minute = mi
            } else {
                comps.hour = 0
                comps.minute = 0
            }
            return Calendar.current.date(from: comps)
        }

        private func currentYear(picker: UIPickerView) -> Int {
            if let col = columns.firstIndex(of: .monthYear) {
                let row = picker.selectedRow(inComponent: col)
                return yearRange.lowerBound + (row / 12)
            }
            if let col = columns.firstIndex(of: .year) {
                return yearRange.lowerBound + picker.selectedRow(inComponent: col)
            }
            return yearRange.lowerBound
        }

        private func currentMonth(picker: UIPickerView) -> Int {
            if let col = columns.firstIndex(of: .monthYear) {
                let row = picker.selectedRow(inComponent: col)
                return (row % 12) + 1
            }
            if let col = columns.firstIndex(of: .month) {
                return picker.selectedRow(inComponent: col) + 1
            }
            return 1
        }

        private func currentDay(picker: UIPickerView) -> Int {
            guard let col = columns.firstIndex(of: .day) else { return 1 }
            return picker.selectedRow(inComponent: col) + 1
        }

        private func daysIn(year: Int, month: Int) -> Int {
            var comps = DateComponents()
            comps.year = year
            comps.month = month
            comps.day = 1
            let cal = Calendar.current
            guard let date = cal.date(from: comps),
                  let range = cal.range(of: .day, in: .month, for: date) else {
                return 31
            }
            return range.count
        }
    }
}
