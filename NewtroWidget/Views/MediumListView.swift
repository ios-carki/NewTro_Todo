import SwiftUI
import WidgetKit

struct MediumListView: View {
    let data: WidgetTodayData

    private var rows: [WidgetTodoItem] {
        Array(data.topItems.prefix(4))
    }

    var body: some View {
        ZStack(alignment: .top) {
            SkyBg()

            VStack(alignment: .leading, spacing: 6) {
                header
                    .padding(.top, 10)
                    .padding(.horizontal, 14)

                VStack(spacing: 4) {
                    ForEach(rows) { item in
                        TodoRow(item: item, fontSize: 11)
                    }
                    if rows.isEmpty {
                        emptyState
                    }
                }
                .padding(.horizontal, 12)

                Spacer(minLength: 0)
            }

            VStack(spacing: 0) {
                Spacer()
                GrassStrip(height: 8)
            }
        }
    }

    private var header: some View {
        HStack {
            Text("오늘의 할 일")
                .font(.galCondensed13())
                .foregroundColor(.ink)
            Spacer()
            HStack(spacing: 8) {
                HStack(spacing: 3) {
                    MiniIcon(kind: .coin, scale: 2)
                    Text("×\(String(format: "%02d", data.coinBalance))")
                        .font(.pressStart9())
                        .foregroundColor(.ink)
                }
                Text("\(data.done)/\(data.total)")
                    .font(.pressStart9())
                    .foregroundColor(.pinkDk)
            }
        }
    }

    private var emptyState: some View {
        MiniPanel(background: .white, padding: 10) {
            HStack {
                Spacer()
                Text("오늘 할 일이 없어요")
                    .font(.galCondensed13())
                    .foregroundColor(.shade)
                Spacer()
            }
        }
    }
}

// MARK: - Todo Row

struct TodoRow: View {
    let item: WidgetTodoItem
    var fontSize: CGFloat = 11

    var body: some View {
        MiniPanel(background: item.done ? Color(hex: "#E8F5D8") : .white, padding: 5) {
            HStack(spacing: 6) {
                MiniCheck(done: item.done, size: fontSize + 1)

                Rectangle()
                    .fill(priorityColor)
                    .frame(width: 4)
                    .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))

                if !item.emoji.isEmpty {
                    Text(item.emoji)
                        .font(.system(size: fontSize - 1))
                }

                Text(item.text)
                    .font(.galCondensed13())
                    .foregroundColor(item.done ? .shade : .ink)
                    .strikethrough(item.done, color: .shade)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let timeLabel = timeLabel {
                    Text("⏱\(timeLabel)")
                        .font(.pressStart8())
                        .foregroundColor(.shade)
                }
            }
        }
    }

    private var priorityColor: Color {
        switch item.priorityColor {
        case .high:   return .pixelRed
        case .medium: return .sun
        case .low:    return .grass
        }
    }

    private var timeLabel: String? {
        guard let due = item.dueTime else { return nil }
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: due)
    }
}
