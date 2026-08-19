import SwiftUI

/// A frosted "liquid glass" panel — heavy blur that dissolves
/// whatever's behind it into soft color, not a clear/sharp
/// see-through pane.
struct GlassPanel: ViewModifier {

    var cornerRadius: CGFloat = 28
    var material: NSVisualEffectView.Material = .hudWindow

    // .behindWindow = blurs the REAL desktop behind the window
    // (strong, diffuse, no seams). .withinWindow blurs SwiftUI
    // content behind it in the same view tree (weaker, and can
    // cause visible seams where two glass panels overlap).
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow

    // Pushed up from ~0.15 → ~0.35 so shapes behind the glass
    // dissolve into color instead of staying legible.
    var tint: Color = .black.opacity(0.35)
    var borderOpacity: Double = 0.35

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    VisualEffectView(
                        material: material,
                        blendingMode: blendingMode,
                        cornerRadius: cornerRadius
                    )
                    tint
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(borderOpacity),
                                .white.opacity(0.04)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.35), radius: 24, y: 10)
    }
}

extension View {
    func glassPanel(
        cornerRadius: CGFloat = 28,
        material: NSVisualEffectView.Material = .hudWindow,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        tint: Color = .black.opacity(0.35),
        borderOpacity: Double = 0.35
    ) -> some View {
        modifier(GlassPanel(
            cornerRadius: cornerRadius,
            material: material,
            blendingMode: blendingMode,
            tint: tint,
            borderOpacity: borderOpacity
        ))
    }
}

/// Colorful blurred backdrop shown through the glass.
struct GlassBackdrop: View {
    var colors: [Color] = [.indigo, .blue, .purple, .black]

    var body: some View {
        ZStack {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            RadialGradient(
                colors: [.cyan.opacity(0.55), .clear],
                center: .topLeading, startRadius: 20, endRadius: 420
            )
            RadialGradient(
                colors: [.purple.opacity(0.6), .clear],
                center: .bottomTrailing, startRadius: 40, endRadius: 520
            )
        }
        .blur(radius: 70)
        .ignoresSafeArea()
    }
}
