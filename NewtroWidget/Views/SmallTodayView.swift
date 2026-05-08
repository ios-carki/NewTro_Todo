import SwiftUI
import WidgetKit

struct SmallTodayView: View {
    let data: WidgetTodayData

    var body: some View {
        ZStack(alignment: .topLeading) {
            SkyBg()

            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, 12)
                    .padding(.horizontal, 12)

                Spacer().frame(height: 8)

                Text("오늘 할 일")
                    .font(.galCondensed13())
                    .foregroundColor(.ink)
                    .padding(.horizontal, 12)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(data.done)")
                        .font(.pressStart28())
                        .foregroundColor(.ink)
                    Text("/\(data.total)")
                        .font(.pressStart14())
                        .foregroundColor(.shade)
                }
                .padding(.top, 2)
                .padding(.horizontal, 12)

                Spacer()

                PixelProgressBar(progress: data.progress, height: 14)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 38)
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    MiniMascot(scale: 2.8)
                        .padding(.trailing, 10)
                        .padding(.bottom, 14)
                }
            }

            VStack(spacing: 0) {
                Spacer()
                GrassStrip(height: 14)
            }
        }
    }

    private var header: some View {
        HStack {
            Text(worldDateLabel)
                .font(.pressStart9())
                .foregroundColor(.peachDk)
            Spacer()
            HStack(spacing: 3) {
                MiniIcon(kind: .coin, scale: 2)
                Text("×\(String(format: "%02d", data.done))")
                    .font(.pressStart9())
                    .foregroundColor(.ink)
            }
        }
    }

    private var worldDateLabel: String {
        let f = DateFormatter()
        f.dateFormat = "MM-dd"
        return "WORLD \(f.string(from: data.date))"
    }
}
