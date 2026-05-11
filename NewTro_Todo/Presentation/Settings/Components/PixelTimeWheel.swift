import SwiftUI
import UIKit

struct PixelTimeWheel: View {
    @Binding var hour: Int      // 0...23
    @Binding var minute: Int    // 0...55 (5분 단위로 스냅됨)

    private let rowHeight: CGFloat = 32
    private var height: CGFloat { rowHeight * 5 }    // 정확히 5행 노출

    var body: some View {
        ThreeColumnPickerRepresentable(
            hour: $hour,
            minute: $minute,
            rowHeight: rowHeight
        )
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipped()
        .padding(.vertical, 4)
        .background(Color.cream)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
    }
}

private struct ThreeColumnPickerRepresentable: UIViewRepresentable {
    @Binding var hour: Int
    @Binding var minute: Int
    let rowHeight: CGFloat

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UIPickerView {
        let pv = UIPickerView()
        pv.dataSource = context.coordinator
        pv.delegate   = context.coordinator
        pv.backgroundColor = .clear
        pv.clipsToBounds = true
        applySelection(on: pv, animated: false)
        return pv
    }

    func updateUIView(_ uiView: UIPickerView, context: Context) {
        context.coordinator.parent = self
        applySelection(on: uiView, animated: false)
    }

    private func applySelection(on pv: UIPickerView, animated: Bool) {
        let parts = Self.split(hour24: hour, minute: minute)
        if pv.selectedRow(inComponent: 0) != parts.period {
            pv.selectRow(parts.period, inComponent: 0, animated: animated)
        }
        if pv.selectedRow(inComponent: 1) != parts.hour12 - 1 {
            pv.selectRow(parts.hour12 - 1, inComponent: 1, animated: animated)
        }
        if pv.selectedRow(inComponent: 2) != parts.minuteIndex {
            pv.selectRow(parts.minuteIndex, inComponent: 2, animated: animated)
        }
    }

    // MARK: - 12h <-> 24h 변환

    static func split(hour24: Int, minute: Int) -> (period: Int, hour12: Int, minuteIndex: Int) {
        let period: Int
        let hour12: Int
        if hour24 == 0 {
            period = 0; hour12 = 12
        } else if hour24 < 12 {
            period = 0; hour12 = hour24
        } else if hour24 == 12 {
            period = 1; hour12 = 12
        } else {
            period = 1; hour12 = hour24 - 12
        }
        let minuteIndex = max(0, min(11, minute / 5))
        return (period, hour12, minuteIndex)
    }

    static func combine(period: Int, hour12: Int, minuteIndex: Int) -> (hour: Int, minute: Int) {
        let hour24: Int
        if period == 0 {
            hour24 = (hour12 == 12) ? 0 : hour12
        } else {
            hour24 = (hour12 == 12) ? 12 : hour12 + 12
        }
        return (hour24, minuteIndex * 5)
    }

    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: ThreeColumnPickerRepresentable

        init(_ parent: ThreeColumnPickerRepresentable) {
            self.parent = parent
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int { 3 }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0: return 2      // 오전 / 오후
            case 1: return 12     // 1 ~ 12
            default: return 12    // 00, 05, ... 55
            }
        }

        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            parent.rowHeight
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            label.font = UIFont(name: "Galmuri11-Bold", size: 18) ?? .boldSystemFont(ofSize: 18)
            label.textColor = .inkC
            label.textAlignment = .center

            switch component {
            case 0:
                label.text = row == 0
                    ? NSLocalizedString("오전", comment: "")
                    : NSLocalizedString("오후", comment: "")
            case 1:
                label.text = String(format: "%d", row + 1)
            default:
                label.text = String(format: "%02d", row * 5)
            }
            return label
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let p  = component == 0 ? row : pickerView.selectedRow(inComponent: 0)
            let h12 = component == 1 ? (row + 1) : (pickerView.selectedRow(inComponent: 1) + 1)
            let mi = component == 2 ? row : pickerView.selectedRow(inComponent: 2)
            let combined = ThreeColumnPickerRepresentable.combine(
                period: p, hour12: h12, minuteIndex: mi
            )
            parent.hour = combined.hour
            parent.minute = combined.minute
        }
    }
}
