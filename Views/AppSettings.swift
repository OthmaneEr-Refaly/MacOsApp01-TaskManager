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

        init(longSessionThresholdHours: Double, chartDays: Int, hasCompletedOnboarding: Bool) {
            self.longSessionThresholdHours = longSessionThresholdHours
            self.chartDays = chartDays
            self.hasCompletedOnboarding = hasCompletedOnboarding
        }

        // Custom decode so ANY future new field defaults gracefully
        // instead of failing the whole decode and silently resetting
        // every other saved value — this is the bug that already hit
        // hasCompletedOnboarding once.
        private enum CodingKeys: String, CodingKey {
            case longSessionThresholdHours, chartDays, hasCompletedOnboarding
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            longSessionThresholdHours = try container.decodeIfPresent(Double.self, forKey: .longSessionThresholdHours) ?? 2
            chartDays = try container.decodeIfPresent(Int.self, forKey: .chartDays) ?? 7
            hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
        }
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
