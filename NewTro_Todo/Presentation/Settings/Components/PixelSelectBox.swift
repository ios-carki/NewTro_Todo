import SwiftUI

struct PixelSelectBoxOption<Value: Hashable>: Identifiable {
    let value: Value
    let label: LocalizedStringKey
    var id: Value { value }
}

struct PixelSelectBox<Value: Hashable>: View {
    let options: [PixelSelectBoxOption<Value>]
    @Binding var selection: Value

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options) { opt in
                segment(opt)
            }
        }
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
    }

    private func segment(_ opt: PixelSelectBoxOption<Value>) -> some View {
        let isOn = selection == opt.value
        return Button {
            withAnimation(.easeOut(duration: 0.12)) { selection = opt.value }
        } label: {
            Text(opt.label)
                .font(.galBold13())
                .foregroundColor(isOn ? .ink : .shade.opacity(0.6))
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(isOn ? Color.sun : Color.cream)
        }
        .buttonStyle(.plain)
    }
}
