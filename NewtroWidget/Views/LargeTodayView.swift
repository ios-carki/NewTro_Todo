import SwiftUI
import WidgetKit

struct LargeTodayView: View {
    let data: WidgetTodayData

    private static let maxRows = 5

    private var rows: [WidgetTodoItem] {
        Array(data.topItems.prefix(Self.maxRows))
    }

    private var emptySlots: Int {
        max(0, Self.maxRows - rows.count)
    }

    var body: some View {
        ZStack(alignment: .top) {
            SkyBg()

            VStack(alignment: .leading, spacing: 0) {
                hudStrip
                    .padding(.top, 14)
                    .padding(.horizontal, 16)

                titleRow
                    .padding(.top, 10)
                    .padding(.horizontal, 16)

                PixelProgressBar(progress: data.progress, height: 14)
                    .padding(.top, 8)
                    .padding(.horizontal, 16)

                if data.total == 0 {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            MiniMascot(scale: 3.2)
                            Text("오늘은 할 일이 없어요")
                                .font(.galBold16())
                                .foregroundColor(.shade)
                        }
                        Spacer()
                    }
                    Spacer()
                } else {
                    VStack(spacing: 5) {
                        ForEach(rows) { item in
                            TodoRow(item: item, fontSize: 12)
                        }
                        ForEach(0..<emptySlots, id: \.self) { _ in
                            TodoRow.placeholder(fontSize: 12)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 14)

                    Spacer(minLength: 0)
                }

                bottomStats
                    .padding(.horizontal, 14)
                    .padding(.bottom, 28)
            }

            VStack(spacing: 0) {
                Spacer()
                GrassStrip(height: 12)
            }
        }
    }

    private var hudStrip: some View {
        HStack {
            HStack(spacing: 4) {
                MiniIcon(kind: .coin, scale: 2)
                Text("×\(String(format: "%02d", data.coinBalance))")
                    .font(.pressStart10())
                    .foregroundColor(.ink)
            }
            Spacer()
            Text(worldDateLabel)
                .font(.pressStart10())
                .foregroundColor(.ink)
            Spacer()
            HStack(spacing: 4) {
                MiniIcon(kind: .heart, scale: 2)
                Text("×\(String(format: "%02d", max(0, 3 - postponedCount)))")
                    .font(.pressStart10())
                    .foregroundColor(.ink)
            }
        }
    }

    private var titleRow: some View {
        HStack(alignment: .lastTextBaseline) {
            Text("오늘의 할 일")
                .font(.galBold20())
                .foregroundColor(.ink)
            Spacer()
            Text("\(data.done)/\(data.total)")
                .font(.pressStart10())
                .foregroundColor(.pinkDk)
        }
    }

    private var bottomStats: some View {
        HStack(spacing: 6) {
            MiniPanel(background: .cream, padding: 6) {
                HStack(spacing: 4) {
                    Spacer()
                    MiniIcon(kind: .flame, scale: 2)
                    Text("\(streakDays)d")
                        .font(.pressStart10())
                        .foregroundColor(.ink)
                    Spacer()
                }
            }
            MiniPanel(background: .sun, padding: 6) {
                HStack(spacing: 4) {
                    Spacer()
                    MiniIcon(kind: .star, scale: 2)
                    Text("×\(perfectDays)")
                        .font(.pressStart10())
                        .foregroundColor(.ink)
                    Spacer()
                }
            }
            MiniPanel(background: .pixelPink, padding: 6) {
                HStack(spacing: 4) {
                    Spacer()
                    MiniMascot(scale: 1.5)
                    Text("핑코")
                        .font(.galCondensed13())
                        .foregroundColor(.ink)
                    Spacer()
                }
            }
        }
    }

    private var worldDateLabel: String {
        let f = DateFormatter()
        f.dateFormat = "MM-dd"
        return "WORLD \(f.string(from: data.date))"
    }

    // PR ⑤에서는 streak/perfect day/postpone count 미연결 — 향후 PR ⑥+에서 실데이터 wire-up
    private var streakDays: Int { 0 }
    private var perfectDays: Int { 0 }
    private var postponedCount: Int { 0 }
}
