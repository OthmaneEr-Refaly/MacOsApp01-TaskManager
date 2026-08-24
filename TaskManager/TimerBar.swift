import SwiftUI

// MARK: - Bottom-left: big time readout, a tick bar that fills
// over each 60-second span and resets, and the project label.
// Tick width is now computed from available space, so it always
// spans the full container width instead of a fixed pixel size.
struct TimerBar: View {

    @ObservedObject var session: WorkSessionState

    private let tickCount = 40

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let elapsed = session.currentElapsed(at: timeline.date)
            let secondsIntoMinute = elapsed % 60
            let filledTicks = Int((Double(secondsIntoMinute) / 60.0) * Double(tickCount))

            VStack(alignment: .leading, spacing: 10) {
                tickBar(filledTicks: filledTicks)

                Text(formatted(elapsed))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(session.isRunning ? .orange : .white)
                    .contentTransition(.numericText())
                    .animation(.default, value: elapsed)

                Text(session.selectedProject?.name ?? "No project selected")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }
        }
    }

    private func tickBar(filledTicks: Int) -> some View {
        GeometryReader { geo in
            let spacing: CGFloat = 5
            let tickWidth = max(2, (geo.size.width - CGFloat(tickCount - 1) * spacing) / CGFloat(tickCount))

            HStack(spacing: spacing) {
                ForEach(0..<tickCount, id: \.self) { i in
                    let isFilled = i < filledTicks
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            isFilled
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        colors: [.orange, .orange.opacity(0.6)],
                                        startPoint: .top, endPoint: .bottom
                                    )
                                  )
                                : AnyShapeStyle(Color.white.opacity(0.15))
                        )
                        .frame(width: tickWidth, height: isFilled ? 26 : 16)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 30)
        .mask(
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.04),
                    .init(color: .black, location: 0.96),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .leading, endPoint: .trailing
            )
        )
    }

    private func formatted(_ totalSeconds: Int) -> String {
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%d:%02d", m, s)
    }
}
