//
//  SessionPanel.swift
//  TaskManager
//
//  Created by Admin on 23/8/2026.
//

import SwiftUI

// MARK: - One unified glass card holding the session controls and
// the timer. Deliberately no glow halo here — flat dark-glass
// fill + the thin metallic rim only, so it doesn't compete with
// the picker button or the window's own animated border.
struct SessionPanel: View {

    @ObservedObject var session: WorkSessionState

    var cornerRadius: CGFloat = 24

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SessionControls(session: session)
            TimerBar(session: session)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .elegantDarkGlow(cornerRadius: cornerRadius, glowOpacity: 0)
    }
}
