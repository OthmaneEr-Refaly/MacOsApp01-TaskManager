//
//  ActiveSessionIndicator.swift
//  TaskManager
//
//  Created by Admin on 1/9/2026.
//

import SwiftUI

// MARK: - A small persistent pill showing "a session is running,"
// visible from any tab other than Home (where the real timer is
// already visible). Tapping it jumps back to Home.
struct ActiveSessionIndicator: View {
    @ObservedObject var session: WorkSessionState
    var onTap: () -> Void

    var body: some View {
        if session.hasProject {
            Button(action: onTap) {
                TimelineView(.periodic(from: .now, by: 1)) { timeline in
                    let elapsed = session.currentElapsed(at: timeline.date)

                    HStack(spacing: 8) {
                        Circle()
                            .fill(session.isRunning ? Color.orange : Color.gray)
                            .frame(width: 8, height: 8)

                        Text(session.selectedProject?.name ?? "")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Text(formatted(elapsed))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
            }
            .buttonStyle(.plain)
            .elegantDarkGlow(cornerRadius: 14, glowOpacity: 0)
        }
    }

    private func formatted(_ totalSeconds: Int) -> String {
        let m = totalSeconds / 60
        let s = totalSeconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
