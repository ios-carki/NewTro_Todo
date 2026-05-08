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

                Spacer().frame(height: 6)

                Text("오늘 할 일")
                    .font(.galCondensed13())
                    .foregroundColor(.shade)
                    .padding(.horizontal, 12)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(data.done)")
                        .font(.pressStart20())
                        .foregroundColor(.ink)
                    Text("/\(data.total)")
                        .font(.pressStart12())
                        .foregroundColor(.shade)
                }
                .padding(.horizontal, 12)

                Spacer()

                PixelProgressBar(progress: data.progress)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 36)
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    MiniMascot(scale: 2.2)
                        .padding(.trailing, 10)
                        .padding(.bottom, 14)
                }
            }

            VStack(spacing: 0) {
                Spacer()
                GrassStrip(height: 12)
            }
        }
    }

    private var header: some View {
        HStack {
            Text(worldDateLabel)
                .font(.pressStart9())
                .foregroundColor(.pinkDk)
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
