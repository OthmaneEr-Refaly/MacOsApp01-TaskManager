import SwiftUI

enum ProjectFilter: String, CaseIterable {
    case active = "Active"
    case completed = "Completed"
    case archived = "Archived"
}

struct ProjectsView: View {
    @ObservedObject var store: ProjectsStore

    @State private var appeared = false
    @State private var filter: ProjectFilter = .active

    private let columns = [GridItem(.adaptive(minimum: 90, maximum: 110), spacing: 20)]

    private var filteredProjects: [ManagedProject] {
        switch filter {
        case .active: return store.projects.filter { $0.status == .active }
        case .completed: return store.projects.filter { $0.status == .completed }
        case .archived: return store.projects.filter { $0.status == .archived }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Projects")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                addButton
            }

            filterRow

            if filteredProjects.isEmpty {
                Text(emptyMessage)
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(Array(filteredProjects.enumerated()), id: \.element.id) { index, project in
                        FolderTile(project: project) {
                            store.formMode = .edit(project)
                        }
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.7)
                        .animation(
                            .spring(response: 0.45, dampingFraction: 0.7)
                                .delay(Double(index) * 0.05),
                            value: appeared
                        )
                    }
                }
            }
        }
        .padding(32)
        .onAppear {
            appeared = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                appeared = true
            }
        }
        .onChange(of: filter) { _, _ in
            appeared = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                appeared = true
            }
        }
    }

    private var emptyMessage: String {
        switch filter {
        case .active: return "No projects yet — tap + to add one."
        case .completed: return "No completed projects yet."
        case .archived: return "No archived projects."
        }
    }

    private var filterRow: some View {
        HStack(spacing: 8) {
            ForEach(ProjectFilter.allCases, id: \.self) { option in
                Button(action: { filter = option }) {
                    Text(option.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(filter == option ? .white : .gray)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                }
                .buttonStyle(.plain)
                .elegantDarkGlow(
                    cornerRadius: 14,
                    borderWidth: filter == option ? 1.5 : 1,
                    glowOpacity: 0
                )
            }
        }
    }

    private var addButton: some View {
        Button(action: { store.formMode = .add }) {
            Image(systemName: "plus")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
        }
        .buttonStyle(.plain)
        .elegantDarkGlow(cornerRadius: 17, glowOpacity: 0)
    }
}

private struct FolderTile: View {
    let project: ManagedProject
    let action: () -> Void

    @State private var isHovering = false

    private var tintColor: Color {
        switch project.status {
        case .completed: return .green
        case .archived: return .gray
        default: return project.quadrant.color
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(tintColor)
                    .opacity(project.status == .archived ? 0.55 : 1)
                    .shadow(color: isHovering ? tintColor.opacity(0.5) : .clear, radius: 10)

                Text(project.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text(
                    project.estimatedHours == project.estimatedHours.rounded()
                        ? "\(Int(project.estimatedHours))h"
                        : String(format: "%.1fh", project.estimatedHours)
                )
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.gray)
            }
            .frame(width: 100)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isHovering ? Color.white.opacity(0.05) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovering ? 1.08 : 1.0)
        .animation(.easeOut(duration: 0.15), value: isHovering)
        .onHover { hovering in
            isHovering = hovering
            if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
        }
    }
}
