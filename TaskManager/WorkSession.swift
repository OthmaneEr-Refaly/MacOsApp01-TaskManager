//
//  WorkSession.swift
//  TaskManager
//
//  Created by Admin on 22/8/2026.
//

import SwiftUI
import Combine
import SwiftUI

// MARK: - Tracks the current work session: which project, whether
// the timer is running, and total elapsed time. Persistence /
// daily-weekly charting comes later — this just holds live state.
@MainActor
final class WorkSessionState: ObservableObject {

    @Published var selectedProject: Project? = nil
    @Published var isRunning: Bool = false

    private var accumulatedSeconds: Int = 0
    private var runStartDate: Date? = nil

    var hasProject: Bool { selectedProject != nil }

    func select(_ project: Project) {
        // Picking a new project while one is running/paused resets
        // the clock — starting a new task means a new session.
        selectedProject = project
        isRunning = false
        accumulatedSeconds = 0
        runStartDate = nil
    }

    func toggleRunPause() {
        guard hasProject else { return }
        if isRunning {
            commitElapsed()
            isRunning = false
        } else {
            runStartDate = Date()
            isRunning = true
        }
    }

    func stop() {
        commitElapsed()
        isRunning = false
        // Later: this is the hook where we'd log the finished
        // session (duration, project, timestamp) for the charts.
        accumulatedSeconds = 0
    }

    /// Current elapsed seconds, live — pass in a TimelineView's
    /// `date` so the UI updates every tick without a Timer object.
    func currentElapsed(at date: Date) -> Int {
        if isRunning, let start = runStartDate {
            return accumulatedSeconds + Int(date.timeIntervalSince(start))
        }
        return accumulatedSeconds
    }

    private func commitElapsed() {
        if let start = runStartDate {
            accumulatedSeconds += Int(Date().timeIntervalSince(start))
        }
        runStartDate = nil
    }
}
