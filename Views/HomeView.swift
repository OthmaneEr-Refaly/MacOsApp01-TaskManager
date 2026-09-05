import SwiftUI

struct HomeView: View {
    @ObservedObject var session: WorkSessionState
    @ObservedObject var projectsStore: ProjectsStore
    @ObservedObject var historyStore: SessionHistoryStore

    var body: some View {
        GeometryReader { geo in
            let contentWidth = geo.size.width - 80

            ZStack {
                ProjectPickerRuler(
                    projects: projectsStore.projects,
                    historyStore: historyStore,
                    hasActiveSession: session.hasProject,
                    activeProjectName: session.selectedProject?.name,
                    onStart: { project in
                        session.select(project)
                    }
                )
                .frame(width: contentWidth)
                .position(x: geo.size.width / 2, y: geo.size.height * 0.38)

                SessionPanel(session: session)
                    .frame(width: contentWidth)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.80)
            }
        }
    }
}
