import SwiftUI
import Combine

@MainActor
final class WorkSessionState: ObservableObject {

    @Published var selectedProject: ManagedProject? = nil
    @Published var isRunning: Bool = false

    private var accumulatedSeconds: Int = 0
    private var runStartDate: Date? = nil
    private var sessionStartedAt: Date? = nil

    private let historyStore: SessionHistoryStore

    init(historyStore: SessionHistoryStore) {
        self.historyStore = historyStore
    }

    var hasProject: Bool { selectedProject != nil }

    func select(_ project: ManagedProject) {
        selectedProject = project
        accumulatedSeconds = 0
        isRunning = true
        runStartDate = Date()
        sessionStartedAt = Date()
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

    // Commits the session to history and ends it — works whether
    // currently running or paused. Zero-duration sessions (picked
    // a project, immediately finished) create no history record.
    func finish() {
        commitElapsed()
        isRunning = false

        if let project = selectedProject, let startedAt = sessionStartedAt, accumulatedSeconds > 0 {
            historyStore.append(HistoricalSession(
                projectID: project.id,
                projectNameSnapshot: project.name,
                startedAt: startedAt,
                endedAt: Date(),
                durationSeconds: accumulatedSeconds
            ))
        }
        reset()
    }

    // Throws the session away entirely — no history record no
    // matter how much time had accumulated. The caller is
    // responsible for confirming this with the user first.
    func discard() {
        reset()
    }

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

    private func reset() {
        accumulatedSeconds = 0
        isRunning = false
        runStartDate = nil
        sessionStartedAt = nil
        selectedProject = nil
    }
}
