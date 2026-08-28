import SwiftUI
import Combine

@MainActor
final class WorkSessionState: ObservableObject {

    @Published var selectedProject: ManagedProject? = nil
    @Published var isRunning: Bool = false

    private var accumulatedSeconds: Int = 0
    private var runStartDate: Date? = nil

    var hasProject: Bool { selectedProject != nil }

    func select(_ project: ManagedProject) {
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
        // Next step: log (selectedProject, accumulatedSeconds, Date())
        // to session history before resetting.
        accumulatedSeconds = 0
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
}
