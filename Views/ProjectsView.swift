import SwiftUI

struct ProjectsView: View {
    @ObservedObject var store: ProjectsStore

    // Drives the staggered entrance — starts false, flips true
    // shortly after appearing so SwiftUI actually animates the
    // transition instead of rendering straight into the end state.
    @State private var appeared = false

    private let columns = [GridItem(.adaptive(minimum: 90, maximum: 110), spacing: 20)]

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
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(Array(store.projects.enumerated()), id: \.element.id) { index, project in
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

// MARK: - A single folder tile with its own hover state (needs a
// dedicated view struct since @State can't live inside a function).
private struct FolderTile: View {
    let project: ManagedProject
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(project.quadrant.color)
                    .shadow(color: isHovering ? project.quadrant.color.opacity(0.5) : .clear, radius: 10)

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
