import SwiftUI
import Combine

// A tiny snapshot written on every transition — start/pause/resume —
// not every tick. Recovery works because currentElapsed(at:) already
// computes from real timestamps, so restoring these same fields
// after a crash produces the exact correct elapsed time for free.
private struct PersistedActiveSession: Codable {
    var project: ManagedProject
    var sessionStartedAt: Date
    var accumulatedSeconds: Int
    var runStartDate: Date?
    var isRunning: Bool
}

@MainActor
final class WorkSessionState: ObservableObject {

    @Published var selectedProject: ManagedProject? = nil
    @Published var isRunning: Bool = false

    private var accumulatedSeconds: Int = 0
    private var runStartDate: Date? = nil
    private var sessionStartedAt: Date? = nil

    private let historyStore: SessionHistoryStore
    private let activeSessionFilename = "activeSession.json"

    init(historyStore: SessionHistoryStore) {
        self.historyStore = historyStore
        restoreActiveSessionIfNeeded()
    }

    var hasProject: Bool { selectedProject != nil }

    func select(_ project: ManagedProject) {
        selectedProject = project
        accumulatedSeconds = 0
        isRunning = true
        runStartDate = Date()
        sessionStartedAt = Date()
        persistActiveSession()
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
        persistActiveSession()
    }

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
        JSONFileStore.delete(activeSessionFilename)
    }

    // MARK: - Crash / force-quit recovery

    private func persistActiveSession() {
        guard let project = selectedProject, let sessionStartedAt else { return }
        let record = PersistedActiveSession(
            project: project,
            sessionStartedAt: sessionStartedAt,
            accumulatedSeconds: accumulatedSeconds,
            runStartDate: runStartDate,
            isRunning: isRunning
        )
        JSONFileStore.save(record, to: activeSessionFilename)
    }

    private func restoreActiveSessionIfNeeded() {
        guard let record = JSONFileStore.load(PersistedActiveSession.self, from: activeSessionFilename) else { return }
        selectedProject = record.project
        sessionStartedAt = record.sessionStartedAt
        accumulatedSeconds = record.accumulatedSeconds
        runStartDate = record.runStartDate
        isRunning = record.isRunning
    }
}
