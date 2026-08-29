import SwiftUI

struct SessionControls: View {

    @ObservedObject var session: WorkSessionState
    @State private var showDiscardConfirm = false

    var body: some View {
        HStack(spacing: 12) {
            ControlIconButton(
                systemImage: session.isRunning ? "pause.fill" : "play.fill",
                tint: .orange,
                active: session.hasProject
            ) {
                session.toggleRunPause()
            }

            // Primary end action — commits the session to history.
            ControlIconButton(
                systemImage: "checkmark",
                tint: .green,
                active: session.hasProject
            ) {
                session.finish()
            }

            // Secondary, destructive — requires confirmation since
            // it throws the time away with no history record.
            ControlIconButton(
                systemImage: "trash",
                tint: .red,
                active: session.hasProject
            ) {
                showDiscardConfirm = true
            }
            .confirmationDialog(
                "Discard this session? The time won't be recorded.",
                isPresented: $showDiscardConfirm,
                titleVisibility: .visible
            ) {
                Button("Discard Session", role: .destructive) {
                    session.discard()
                }
                Button("Cancel", role: .cancel) {}
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
