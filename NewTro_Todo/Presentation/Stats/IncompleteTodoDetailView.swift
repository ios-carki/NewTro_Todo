import SwiftUI

struct IncompleteTodoDetailView: View {
    let todo: TodoEntity

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                titleSection
                metaSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(
            BackgroundSceneryView()
                .ignoresSafeArea()
        )
        .navigationTitle("상세")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                ImportancePip(importance: todo.importance)
                Text(importanceLabel)
                    .font(.galBold11())
                    .foregroundColor(.shade)
                Spacer()
                ColorChip(name: todo.colorName)
            }

            Text(todo.text)
                .font(.galBold16())
                .foregroundColor(.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
    }

    private var metaSection: some View {
        VStack(spacing: 0) {
            metaRow(label: "날짜", value: dateString(todo.targetDate))
            divider
            metaRow(label: "진행 시간", value: timeRangeString)
            divider
            metaRow(label: "알림", value: notifyString)
            divider
            metaRow(label: "작성일", value: dateTimeString(todo.createdAt))
        }
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 3, y: 3))
    }

    private func metaRow(label: String, value: String) -> some View {
        HStack {
            Text(label.localized())
                .font(.galBold11())
                .foregroundColor(.shade)
            Spacer()
            Text(value)
                .font(.pressStart9())
                .foregroundColor(.ink)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var divider: some View {
        Rectangle().fill(Color.ink.opacity(0.15)).frame(height: 1)
    }

    private var importanceLabel: String {
        switch todo.importance {
        case .high:   return "중요도 높음".localized()
        case .medium: return "중요도 보통".localized()
        case .none:   return "중요도 없음".localized()
        }
    }

    private var timeRangeString: String {
        if todo.isAllDay { return "종일".localized() }
        guard let start = todo.targetTimeStart else { return "-" }
        if let end = todo.targetTimeEnd {
            return "\(hhmm(start)) ~ \(hhmm(end))"
        }
        return hhmm(start)
    }

    private var notifyString: String {
        guard let notify = todo.notifyAt else { return "-" }
        return dateTimeString(notify)
    }

    private func hhmm(_ date: Date) -> String {
        let cal = Calendar.current
        return String(format: "%02d:%02d",
                      cal.component(.hour, from: date),
                      cal.component(.minute, from: date))
    }

    private func dateString(_ date: Date) -> String {
        let cal = Calendar.current
        return String(format: "%04d.%02d.%02d",
                      cal.component(.year, from: date),
                      cal.component(.month, from: date),
                      cal.component(.day, from: date))
    }

    private func dateTimeString(_ date: Date) -> String {
        let cal = Calendar.current
        return String(format: "%04d.%02d.%02d %02d:%02d",
                      cal.component(.year, from: date),
                      cal.component(.month, from: date),
                      cal.component(.day, from: date),
                      cal.component(.hour, from: date),
                      cal.component(.minute, from: date))
    }
}

private struct ColorChip: View {
    let name: String

    var body: some View {
        Rectangle()
            .fill(MemoColorPalette.color(for: name))
            .frame(width: 18, height: 18)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))
    }
}
