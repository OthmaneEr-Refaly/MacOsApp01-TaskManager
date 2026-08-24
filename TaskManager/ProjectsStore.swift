import SwiftUI
import Combine

struct ManagedProject: Identifiable {
    let id = UUID()
    var name: String
    var estimatedHours: Double
    var quadrant: PriorityQuadrant
}

@MainActor
final class ProjectsStore: ObservableObject {
    @Published var projects: [ManagedProject] = []

    // Drives the full-screen add-project overlay from ContentView.
    @Published var isAdding: Bool = false

    func add(_ project: ManagedProject) {
        projects.append(project)
    }
}
