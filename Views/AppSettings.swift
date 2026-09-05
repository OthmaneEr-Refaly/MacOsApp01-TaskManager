import SwiftUI
import Combine

@MainActor
final class AppSettings: ObservableObject {

    private let filename = "settings.json"

    @Published var longSessionThresholdHours: Double {
        didSet { persist() }
    }
    @Published var chartDays: Int {
        didSet { persist() }
    }
    @Published var hasCompletedOnboarding: Bool {
        didSet { persist() }
    }

    private struct Persisted: Codable {
        var longSessionThresholdHours: Double
        var chartDays: Int
        var hasCompletedOnboarding: Bool
    }

    init() {
        if let loaded = JSONFileStore.load(Persisted.self, from: "settings.json") {
            self.longSessionThresholdHours = loaded.longSessionThresholdHours
            self.chartDays = loaded.chartDays
            self.hasCompletedOnboarding = loaded.hasCompletedOnboarding
        } else {
            self.longSessionThresholdHours = 2
            self.chartDays = 7
            self.hasCompletedOnboarding = false
        }
    }

    private func persist() {
        JSONFileStore.save(
            Persisted(
                longSessionThresholdHours: longSessionThresholdHours,
                chartDays: chartDays,
                hasCompletedOnboarding: hasCompletedOnboarding
            ),
            to: filename
        )
    }
}
