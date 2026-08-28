import SwiftUI

struct HomeView: View {
    @ObservedObject var session: WorkSessionState
    @ObservedObject var projectsStore: ProjectsStore

    var body: some View {
        GeometryReader { geo in
            let contentWidth = geo.size.width - 80

            ZStack {
                ProjectPickerRuler(
                    projects: projectsStore.projects,
                    onSelect: { project in
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
