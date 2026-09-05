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
        normalizeDuplicateNames()
        refreshSnoozeExpirations()
    }

    // MARK: - Duplicate-name handling (auto-suffix)

    /// Returns a name guaranteed unique (case-insensitive) among all
    /// projects except `excludingID`. Trims whitespace; if `desired`
    /// is taken, appends/increments " (2)", " (3)", ...
    /// e.g. "Website" -> "Website (2)" -> "Website (3)".
    func uniqueName(for desired: String, excludingID: UUID? = nil) -> String {
        let trimmed = desired.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }

        var taken = Set<String>()
        for p in projects where p.id != excludingID {
            taken.insert(p.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
        }

        if !taken.contains(trimmed.lowercased()) {
            return trimmed
        }

        let root = ProjectsStore.strippingSuffix(from: trimmed)
        var n = 2
        while taken.contains("\(root) (\(n))".lowercased()) {
            n += 1
        }
        return "\(root) (\(n))"
    }

    /// Strips a trailing " (N)" so "Website (2)" -> "Website",
    /// avoiding ugly "Website (2) (2)" chains.
    private static func strippingSuffix(from name: String) -> String {
        guard name.hasSuffix(")"),
              let openRange = name.range(of: " (", options: .backwards) else {
            return name
        }
        let afterOpen = name[openRange.upperBound...] // e.g. "2)"
        guard afterOpen.hasSuffix(")"), afterOpen.count >= 2 else { return name }
        let numberPart = afterOpen.dropLast()
        guard !numberPart.isEmpty, numberPart.allSatisfy({ $0.isNumber }) else { return name }
        let root = String(name[..<openRange.lowerBound])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !root.isEmpty else { return name }
        return root
    }

    /// One-time repair for duplicates created before auto-suffix
    /// existed: keeps the first occurrence's name, renames later
    /// ones in load order. Persists only if something changed.
    private func normalizeDuplicateNames() {
        var seen = Set<String>()
        var changed = false
        for i in projects.indices {
            let current = projects[i].name.trimmingCharacters(in: .whitespacesAndNewlines)
            if current.isEmpty { continue }
            if !seen.contains(current.lowercased()) {
                seen.insert(current.lowercased())
                if projects[i].name != current {
                    projects[i].name = current
                    changed = true
                }
            } else {
                let root = ProjectsStore.strippingSuffix(from: current)
                var n = 2
                while seen.contains("\(root) (\(n))".lowercased()) {
                    n += 1
                }
                projects[i].name = "\(root) (\(n))"
                seen.insert(projects[i].name.lowercased())
                changed = true
            }
        }
        if changed {
            persist()
        }
    }

    func add(_ project: ManagedProject) {
        var uniqued = project
        uniqued.name = uniqueName(for: project.name)
        projects.append(uniqued)
    }

    func update(_ project: ManagedProject) {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else { return }
        var uniqued = project
        uniqued.name = uniqueName(for: project.name, excludingID: project.id)
        projects[index] = uniqued
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
