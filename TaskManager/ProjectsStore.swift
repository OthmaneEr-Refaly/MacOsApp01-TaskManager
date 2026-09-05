import SwiftUI
import Combine

enum ProjectStatus: Equatable {
    case active
    case completed
    case snoozed(until: Date) // model supports it now; snooze UI comes later
    case archived
}

extension ProjectStatus: Codable {
    private enum CodingKeys: String, CodingKey {
        case type, until
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "completed": self = .completed
        case "archived": self = .archived
        case "snoozed":
            let until = try container.decode(Date.self, forKey: .until)
            self = .snoozed(until: until)
        default: self = .active
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .active: try container.encode("active", forKey: .type)
        case .completed: try container.encode("completed", forKey: .type)
        case .archived: try container.encode("archived", forKey: .type)
        case .snoozed(let until):
            try container.encode("snoozed", forKey: .type)
            try container.encode(until, forKey: .until)
        }
    }
}

struct ManagedProject: Identifiable, Codable {
    let id: UUID
    var name: String
    var estimatedHours: Double
    var quadrant: PriorityQuadrant
    var status: ProjectStatus

    init(
        id: UUID = UUID(),
        name: String,
        estimatedHours: Double,
        quadrant: PriorityQuadrant,
        status: ProjectStatus = .active
    ) {
        self.id = id
        self.name = name
        self.estimatedHours = estimatedHours
        self.quadrant = quadrant
        self.status = status
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, estimatedHours, quadrant, status
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        estimatedHours = try container.decode(Double.self, forKey: .estimatedHours)
        quadrant = try container.decode(PriorityQuadrant.self, forKey: .quadrant)
        status = try container.decodeIfPresent(ProjectStatus.self, forKey: .status) ?? .active
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(estimatedHours, forKey: .estimatedHours)
        try container.encode(quadrant, forKey: .quadrant)
        try container.encode(status, forKey: .status)
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

    @Published var projects: [ManagedProject] {
        didSet { persist() }
    }

    @Published var formMode: ProjectFormMode? = nil

    init() {
        self.projects = JSONFileStore.load([ManagedProject].self, from: filename) ?? []
        refreshSnoozeExpirations()
    }

    func add(_ project: ManagedProject) {
        projects.append(project)
    }

    func update(_ project: ManagedProject) {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else { return }
        projects[index] = project
    }

    func archive(_ project: ManagedProject) {
        setStatus(.archived, for: project)
    }

    func setSnoozed(_ project: ManagedProject, until: Date) {
        setStatus(.snoozed(until: until), for: project)
    }

    // Called on load and whenever the Projects tab appears — any
    // snoozed project whose date has passed goes back to .active
    // automatically, no reload/relaunch required.
    func refreshSnoozeExpirations() {
        let now = Date()
        for i in projects.indices {
            if case .snoozed(let until) = projects[i].status, until <= now {
                projects[i].status = .active
            }
        }
    }

    func complete(_ project: ManagedProject) {
        setStatus(.completed, for: project)
    }

    // Brings a Completed or Archived project back into rotation —
    // the "undo" for what used to be a one-way door.
    func reactivate(_ project: ManagedProject) {
        setStatus(.active, for: project)
    }

    private func setStatus(_ status: ProjectStatus, for project: ManagedProject) {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else { return }
        projects[index].status = status
    }

    func delete(_ project: ManagedProject) {
        projects.removeAll { $0.id == project.id }
    }

    private func persist() {
        JSONFileStore.save(projects, to: filename)
    }
}
