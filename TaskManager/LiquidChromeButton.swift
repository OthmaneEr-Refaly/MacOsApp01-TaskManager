import SwiftUI

// MARK: - The animated "liquid chrome" surface. v2: wider
// brightness swing (so blendMode(.difference) on the text actually
// has something to react against), less blur (so shapes stay
// distinct instead of melting into a flat smear), plus a traveling
// specular streak — real metal reads mostly by its moving highlight,
// not just diffuse color drift.
struct LiquidChromeBackground: View {
    var baseColor: Color = Color(white: 0.05)
    var speed: Double = 2
    var amplitude: Double = 0.1

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate * speed
                let w = geo.size.width
                let h = geo.size.height
                let swing = amplitude * 3 // old value barely moved at all

                ZStack {
                    baseColor

                    blob(cx: 0.3 + swing * sin(t), cy: 0.4 + swing * cos(t * 0.7),
                         radius: max(w, h) * 0.55, w: w, h: h, color: .white.opacity(0.28))
                    blob(cx: 0.7 + swing * cos(t * 0.9 + 1), cy: 0.6 + swing * sin(t * 0.5 + 2),
                         radius: max(w, h) * 0.5, w: w, h: h, color: .black.opacity(0.55))
                    blob(cx: 0.5 + swing * sin(t * 1.4 + 3), cy: 0.5 + swing * cos(t * 1.1 + 1.5),
                         radius: max(w, h) * 0.4, w: w, h: h, color: .white.opacity(0.16))

                    shine(t: t, w: w, h: h)
                }
                .blur(radius: min(w, h) * 0.05)
            }
        }
    }

    private func blob(cx: Double, cy: Double, radius: CGFloat, w: CGFloat, h: CGFloat, color: Color) -> some View {
        RadialGradient(colors: [color, .clear], center: .center, startRadius: 0, endRadius: radius)
            .frame(width: radius * 2.2, height: radius * 2.2)
            .position(x: w * cx, y: h * cy)
    }

    // A bright diagonal band sweeping left-to-right on a loop —
    // the actual "chrome glint" cue.
    private func shine(t: Double, w: CGFloat, h: CGFloat) -> some View {
        let cycle = 4.0
        let progress = t.truncatingRemainder(dividingBy: cycle) / cycle
        let x = -w * 0.6 + CGFloat(progress) * (w * 2.2)

        return LinearGradient(
            colors: [.clear, .white.opacity(0.7), .clear],
            startPoint: .leading, endPoint: .trailing
        )
        .frame(width: w * 0.4, height: h * 1.8)
        .rotationEffect(.degrees(18))
        .position(x: x, y: h / 2)
    }
}

private struct LiquidChromePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.075), value: configuration.isPressed)
    }
}

struct LiquidChromeButton<Label: View>: View {
    var cornerRadius: CGFloat = 100
    var speed: Double = 2
    var amplitude: Double = 0.1
    var baseColor: Color = Color(white: 0.05)
    var action: () -> Void
    @ViewBuilder var label: () -> Label

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            label()
                .blendMode(.difference)
                .background(
                    LiquidChromeBackground(baseColor: baseColor, speed: speed, amplitude: amplitude)
                        .opacity(isHovering ? 1.0 : 0.85)
                        .animation(.easeInOut(duration: 0.5), value: isHovering)
                )
                .compositingGroup()
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color(white: 0.08), lineWidth: 2)
                )
        }
        .buttonStyle(LiquidChromePressStyle())
        .onHover { hovering in
            isHovering = hovering
            if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
        }
    }
}
