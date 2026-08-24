import SwiftUI

// MARK: - Dark glass fill with a plain neutral rim. The rim used
// to be an AngularGradient mixing white/gray/orange (the "metallic"
// look) — that's what was still reading as color everywhere even
// with glow shadows at 0. Stripped to a flat, colorless stroke as
// the new blank-slate baseline.
struct ElegantDarkGlow: ViewModifier {

    var cornerRadius: CGFloat = 100
    var fillColor: Color = Color(red: 0.03, green: 0.03, blue: 0.035)
    var borderWidth: CGFloat = 1
    var borderColor: Color = .white.opacity(0.10)
    var glowColor: Color = .white
    var glowRadius: CGFloat = 18
    var glowOpacity: Double = 0

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [fillColor.opacity(1), fillColor.opacity(0.9), .black],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: borderWidth)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: glowColor.opacity(glowOpacity), radius: glowRadius)
            .shadow(color: .black.opacity(0.5), radius: 20, y: 12)
    }
}

extension View {
    func elegantDarkGlow(
        cornerRadius: CGFloat = 100,
        fillColor: Color = Color(red: 0.03, green: 0.03, blue: 0.035),
        borderWidth: CGFloat = 1,
        borderColor: Color = .white.opacity(0.10),
        glowColor: Color = .white,
        glowRadius: CGFloat = 18,
        glowOpacity: Double = 0
    ) -> some View {
        modifier(ElegantDarkGlow(
            cornerRadius: cornerRadius, fillColor: fillColor, borderWidth: borderWidth,
            borderColor: borderColor, glowColor: glowColor, glowRadius: glowRadius, glowOpacity: glowOpacity
        ))
    }
}

// MARK: - Kept for later — not currently used anywhere, since the
// window's animated border was removed. Revisit when redesigning.
struct AnimatedGlowBorder: View {

    var cornerRadius: CGFloat = 20
    var lineWidth: CGFloat = 2.5
    var glowLineWidth: CGFloat = 12
    var glowBlur: CGFloat = 14
    var speed: Double = 6
    var colors: [Color] = [
        .white, .gray.opacity(0.3), .white.opacity(0.1),
        .orange.opacity(0.5), .white, .gray.opacity(0.3), .white
    ]

    var body: some View {
        GeometryReader { geo in
            let diagonal = sqrt(pow(geo.size.width, 2) + pow(geo.size.height, 2)) * 1.5

            TimelineView(.animation) { timeline in
                let seconds = timeline.date.timeIntervalSinceReferenceDate
                let rotation = (seconds.truncatingRemainder(dividingBy: speed) / speed) * 360

                ZStack {
                    AngularGradient(colors: colors, center: .center)
                        .frame(width: diagonal, height: diagonal)
                        .rotationEffect(.degrees(rotation))
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        .mask(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .strokeBorder(lineWidth: glowLineWidth)
                                .frame(width: geo.size.width, height: geo.size.height)
                        )
                        .blur(radius: glowBlur)
                        .opacity(0.85)

                    AngularGradient(colors: colors, center: .center)
                        .frame(width: diagonal, height: diagonal)
                        .rotationEffect(.degrees(rotation))
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        .mask(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .strokeBorder(lineWidth: lineWidth)
                                .frame(width: geo.size.width, height: geo.size.height)
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }
}
