import SwiftUI

struct ProjectsView: View {
    @ObservedObject var store: ProjectsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Projects")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                addButton
            }

            if store.projects.isEmpty {
                Text("No projects yet — tap + to add one.")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            }

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(store.projects) { project in
                        projectRow(project)
                    }
                }
            }
        }
        .padding(32)
    }

    private var addButton: some View {
        Button(action: { store.isAdding = true }) {
            Image(systemName: "plus")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
        }
        .buttonStyle(.plain)
        .elegantDarkGlow(cornerRadius: 17, glowOpacity: 0)
    }

    private func projectRow(_ project: ManagedProject) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text(project.quadrant.rawValue)
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
            }
            Spacer()
            Text(
                project.estimatedHours == project.estimatedHours.rounded()
                    ? "\(Int(project.estimatedHours))h"
                    : String(format: "%.1fh", project.estimatedHours)
            )
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.orange)
        }
        .padding(16)
        .elegantDarkGlow(cornerRadius: 14, glowOpacity: 0)
    }
}
