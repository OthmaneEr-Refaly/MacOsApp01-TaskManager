import SwiftUI

struct DurationTickSlider: View {
    @Binding var hours: Double
    var maxHours: Double = 12
    var step: Double = 0.5

    var tickCount: Int = 48
    var filledTickHeight: CGFloat = 26
    var unfilledTickHeight: CGFloat = 16
    var barHeight: CGFloat = 30
    var readoutFontSize: CGFloat = 26

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            tickBar
            Text(formatted(hours))
                .font(.system(size: readoutFontSize, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)
        }
    }

    private var tickBar: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 5
            let tickWidth = max(2, (geo.size.width - CGFloat(tickCount - 1) * spacing) / CGFloat(tickCount))
            let filledTicks = Int((hours / maxHours) * Double(tickCount))

            HStack(spacing: spacing) {
                ForEach(0..<tickCount, id: \.self) { i in
                    let isFilled = i < filledTicks
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            isFilled
                                ? AnyShapeStyle(LinearGradient(colors: [.orange, .orange.opacity(0.6)],
                                                                startPoint: .top, endPoint: .bottom))
                                : AnyShapeStyle(Color.white.opacity(0.15))
                        )
                        .frame(width: tickWidth, height: isFilled ? filledTickHeight : unfilledTickHeight)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            // highPriorityGesture — on macOS a plain Shape-based drag
            // target can lose continued mouse-dragged tracking to the
            // window's own move-by-background behavior after the
            // initial click. This forces SwiftUI's gesture to win.
            .highPriorityGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        let fraction = min(max(value.location.x / geo.size.width, 0), 1)
                        let raw = fraction * maxHours
                        hours = (raw / step).rounded() * step
                    }
                    .onEnded { value in
                        let fraction = min(max(value.location.x / geo.size.width, 0), 1)
                        let raw = fraction * maxHours
                        hours = (raw / step).rounded() * step
                    }
            )
        }
        .frame(height: barHeight)
    }

    private func formatted(_ h: Double) -> String {
        h == h.rounded() ? "\(Int(h))h" : String(format: "%.1fh", h)
    }
}
