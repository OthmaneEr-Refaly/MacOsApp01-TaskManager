import SwiftUI

// Time-estimate stepper, rebuilt reader-free. The previous
// implementation measured its own width with GeometryReader to
// size each tick, and press delivery to the +/- buttons died
// completely (hover worked, clicks never fired) in every layout
// arrangement and button style tried — alongside a layout
// recursion warning in the console. This version uses fixed-size
// ticks in a plain centered strip, so no geometry is read
// anywhere in this view, plus two round stepper buttons built
// exactly like the working close button (plain + dark glow).
struct DurationTickSlider: View {
    @Binding var hours: Double
    var maxHours: Double = 12
    var step: Double = 0.5

    var tickCount: Int = 24
    var filledTickHeight: CGFloat = 14
    var unfilledTickHeight: CGFloat = 9
    var barHeight: CGFloat = 16
    var readoutFontSize: CGFloat = 15

    // Fixed tick geometry: the strip centers in whatever space is
    // available and clips symmetrically when narrow. Purely visual.
    private let tickWidth: CGFloat = 5
    private let tickSpacing: CGFloat = 4

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formatted(hours))
                .font(.system(size: readoutFontSize, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)

            HStack(spacing: 12) {
                stepperButton(systemImage: "minus") {
                    hours = max(0, hours - step)
                }

                tickStrip

                stepperButton(systemImage: "plus") {
                    hours = min(maxHours, hours + step)
                }
            }
        }
    }

    private var tickStrip: some View {
        let filledTicks = Int((hours / maxHours) * Double(tickCount))

        return HStack(spacing: tickSpacing) {
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
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: max(barHeight, filledTickHeight))
        .clipped()
    }

    private func stepperButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
        .elegantDarkGlow(cornerRadius: 20, glowOpacity: 0)
    }

    private func formatted(_ h: Double) -> String {
        h == h.rounded() ? "\(Int(h))h" : String(format: "%.1fh", h)
    }
}
