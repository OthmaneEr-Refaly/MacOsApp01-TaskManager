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

            HStack(spacing: 10) {
                Text(formatted(hours))
                    .font(.system(size: readoutFontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)

                Spacer()

                stepperButton(systemImage: "minus") {
                    hours = max(0, hours - step)
                }
                stepperButton(systemImage: "plus") {
                    hours = min(maxHours, hours + step)
                }
            }
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
        }
        .frame(height: barHeight)
        // Purely visual now. Clicking here was fighting the
        // window's own move-by-background behavior and could
        // never reliably win — the stepper below is the real,
        // actually-reliable control.
        .allowsHitTesting(false)
    }

    private func stepperButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
        }
        .buttonStyle(.plain)
        .elegantDarkGlow(cornerRadius: 13, glowOpacity: 0)
    }

    private func formatted(_ h: Double) -> String {
        h == h.rounded() ? "\(Int(h))h" : String(format: "%.1fh", h)
    }
}
