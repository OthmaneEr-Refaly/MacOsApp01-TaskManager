import SwiftUI

// MARK: - Bottom-right: single Start/Pause toggle + Stop.
// Flat now — active/inactive is shown only by icon tint, no glow
// or hover state.
struct SessionControls: View {

    @ObservedObject var session: WorkSessionState

    var body: some View {
        HStack(spacing: 12) {
            ControlIconButton(
                systemImage: session.isRunning ? "pause.fill" : "play.fill",
                tint: .orange,
                active: session.hasProject
            ) {
                session.toggleRunPause()
            }

            ControlIconButton(
                systemImage: "stop.fill",
                tint: .red,
                active: session.hasProject
            ) {
                session.stop()
            }
        }
    }
}

private struct ControlIconButton: View {
    let systemImage: String
    let tint: Color
    let active: Bool
    let action: () -> Void

    var size: CGFloat = 38

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size * 0.34, weight: .semibold))
                .foregroundStyle(active ? tint : .gray.opacity(0.35))
                .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .elegantDarkGlow(cornerRadius: size / 2, glowOpacity: 0)
        .disabled(!active)
    }
}
