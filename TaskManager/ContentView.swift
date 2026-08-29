import SwiftUI

struct WindowDesign {
    var backgroundColor: Color = Color(red: 0.05, green: 0.05, blue: 0.06)
    var windowCornerRadius: CGFloat = 12

    static let `default` = WindowDesign()
}

struct ContentView: View {

    var design: WindowDesign

    @StateObject private var session: WorkSessionState
    @StateObject private var historyStore: SessionHistoryStore
    @StateObject private var projectsStore = ProjectsStore()
    @State private var selectedTab: AppTab = .home

    init(design: WindowDesign = .default) {
        self.design = design
        let history = SessionHistoryStore()
        _historyStore = StateObject(wrappedValue: history)
        _session = StateObject(wrappedValue: WorkSessionState(historyStore: history))
    }

    var body: some View {
        ZStack {
            design.backgroundColor
                .ignoresSafeArea()

            Group {
                switch selectedTab {
                case .home:
                    HomeView(session: session, projectsStore: projectsStore)
                case .projects:
                    ProjectsView(store: projectsStore)
                case .stats:
                    StatsView(historyStore: historyStore)
                }
            }

            VStack {
                HStack {
                    Spacer()
                    TabBar(selected: $selectedTab)
                    Spacer()
                }
                .padding(.top, 34)
                Spacer()
            }

            if projectsStore.formMode != nil {
                AddProjectView(store: projectsStore)
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.25), value: projectsStore.formMode != nil)
        .background(WindowChromeSetup())
    }
}

struct WindowChromeSetup: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.isMovableByWindowBackground = true
                window.isOpaque = true
                window.hasShadow = true
            }
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

#Preview {
    ContentView()
        .frame(width: 700, height: 560)
}
