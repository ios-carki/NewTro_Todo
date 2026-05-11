import SwiftUI
import UIKit

struct PixelTimeWheel: View {
    @Binding var hour: Int
    @Binding var minute: Int

    var body: some View {
        ZStack {
            HourMinutePickerRepresentable(hour: $hour, minute: $minute)
                .frame(height: 132)
                .padding(.horizontal, 6)

            HStack {
                Spacer()
                Text(":")
                    .font(.galBold22())
                    .foregroundColor(.ink)
                    .offset(y: -1)
                Spacer()
            }
            .allowsHitTesting(false)
        }
        .background(Color.cream)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
    }
}

private struct HourMinutePickerRepresentable: UIViewRepresentable {
    @Binding var hour: Int
    @Binding var minute: Int

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UIPickerView {
        let pv = UIPickerView()
        pv.dataSource = context.coordinator
        pv.delegate   = context.coordinator
        pv.backgroundColor = .clear
        pv.selectRow(hour,   inComponent: 0, animated: false)
        pv.selectRow(minute, inComponent: 1, animated: false)
        return pv
    }

    func updateUIView(_ uiView: UIPickerView, context: Context) {
        context.coordinator.parent = self
        if uiView.selectedRow(inComponent: 0) != hour {
            uiView.selectRow(hour, inComponent: 0, animated: false)
        }
        if uiView.selectedRow(inComponent: 1) != minute {
            uiView.selectRow(minute, inComponent: 1, animated: false)
        }
    }

    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: HourMinutePickerRepresentable

        init(_ parent: HourMinutePickerRepresentable) {
            self.parent = parent
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            component == 0 ? 24 : 60
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            label.text = String(format: "%02d", row)
            label.font = UIFont(name: "Galmuri11-Bold", size: 22) ?? .boldSystemFont(ofSize: 22)
            label.textColor = .inkC
            label.textAlignment = .center
            return label
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if component == 0 {
                parent.hour = row
            } else {
                parent.minute = row
            }
        }
    }
}
