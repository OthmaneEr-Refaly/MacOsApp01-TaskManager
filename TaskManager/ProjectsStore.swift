import SwiftUI
import Combine

struct ManagedProject: Identifiable, Codable {
    let id: UUID
    var name: String
    var estimatedHours: Double
    var quadrant: PriorityQuadrant

    init(id: UUID = UUID(), name: String, estimatedHours: Double, quadrant: PriorityQuadrant) {
        self.id = id
        self.name = name
        self.estimatedHours = estimatedHours
        self.quadrant = quadrant
    }
}

enum ProjectFormMode: Equatable {
    case add
    case edit(ManagedProject)

    static func == (lhs: ProjectFormMode, rhs: ProjectFormMode) -> Bool {
        switch (lhs, rhs) {
        case (.add, .add): return true
        case (.edit(let a), .edit(let b)): return a.id == b.id
        default: return false
        }
    }
}

@MainActor
final class ProjectsStore: ObservableObject {

    private let filename = "projects.json"

    // Saves automatically any time the array changes — add, edit,
    // or delete all funnel through this one property.
    @Published var projects: [ManagedProject] {
        didSet { persist() }
    }

    @Published var formMode: ProjectFormMode? = nil

    init() {
        self.projects = JSONFileStore.load([ManagedProject].self, from: filename) ?? []
    }

    func add(_ project: ManagedProject) {
        projects.append(project)
    }

    func update(_ project: ManagedProject) {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else { return }
        projects[index] = project
    }

    func delete(_ project: ManagedProject) {
        projects.removeAll { $0.id == project.id }
    }

    private func persist() {
        JSONFileStore.save(projects, to: filename)
    }
}
