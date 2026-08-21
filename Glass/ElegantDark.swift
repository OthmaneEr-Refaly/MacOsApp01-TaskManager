import SwiftUI

// MARK: - Elegant dark, glowing-rim style — glossy black fill,
// thin metallic border with a light sweep, soft glow + drop shadow.
struct ElegantDarkGlow: ViewModifier {

    var cornerRadius: CGFloat = 100
    var fillColor: Color = Color(red: 0.03, green: 0.03, blue: 0.035)
    var borderWidth: CGFloat = 2
    var glowColor: Color = .white
    var glowRadius: CGFloat = 18
    var glowOpacity: Double = 0.18

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
                        .strokeBorder(
                            AngularGradient(
                                colors: [
                                    .white.opacity(0.9), .gray.opacity(0.3), .white.opacity(0.1),
                                    .orange.opacity(0.35), .white.opacity(0.9), .gray.opacity(0.3), .white.opacity(0.9)
                                ],
                                center: .center
                            ),
                            lineWidth: borderWidth
                        )
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
        borderWidth: CGFloat = 2,
        glowColor: Color = .white,
        glowRadius: CGFloat = 18,
        glowOpacity: Double = 0.18
    ) -> some View {
        modifier(ElegantDarkGlow(
            cornerRadius: cornerRadius, fillColor: fillColor, borderWidth: borderWidth,
            glowColor: glowColor, glowRadius: glowRadius, glowOpacity: glowOpacity
        ))
    }
}

// MARK: - Animated glowing border that traces a rounded-rect
// perimeter. Shape stays fixed — only the light travels.
// Driven by elapsed time (not a one-shot animation), so `speed`
// can change live — e.g. spin faster while "thinking," then ease
// back to a calm pace once a result lands.
struct AnimatedGlowBorder: View {

    var cornerRadius: CGFloat = 20
    var lineWidth: CGFloat = 2.5
    var glowLineWidth: CGFloat = 12
    var glowBlur: CGFloat = 14
    var speed: Double = 6 // seconds per full revolution — lower = faster
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
