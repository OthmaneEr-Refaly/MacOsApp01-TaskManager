import SwiftUI
import Combine

struct WindowDesign {
    var backgroundColor: Color = Color(red: 0.05, green: 0.05, blue: 0.06)
    var windowCornerRadius: CGFloat = 12

    static let `default` = WindowDesign()
}

struct ContentView: View {

    var design: WindowDesign = .default

    @ObservedObject var session: WorkSessionState
    @ObservedObject var historyStore: SessionHistoryStore
    @StateObject private var projectsStore = ProjectsStore()
    @StateObject private var settings = AppSettings()
    @State private var selectedTab: AppTab = .home

    // Long-session nudge — a one-time check-in per session, not a
    // repeating nag. Threshold now comes from Settings.
    @State private var showLongSessionWarning = false
    @State private var hasWarnedThisSession = false

    var body: some View {
        ZStack {
            design.backgroundColor
                .ignoresSafeArea()

            Group {
                switch selectedTab {
                case .home:
                    HomeView(session: session, projectsStore: projectsStore, historyStore: historyStore)
                case .projects:
                    ProjectsView(store: projectsStore)
                case .stats:
                    StatsView(historyStore: historyStore, chartDays: settings.chartDays)
                case .settings:
                    SettingsView(settings: settings, projectsStore: projectsStore, historyStore: historyStore)
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
                AddProjectView(store: projectsStore, session: session, selectedTab: $selectedTab)
            }

            if !settings.hasCompletedOnboarding {
                OnboardingView {
                    settings.hasCompletedOnboarding = true
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            if selectedTab != .home {
                ActiveSessionIndicator(session: session) {
                    selectedTab = .home
                }
                .padding(.top, 34)
                .padding(.trailing, 24)
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.25), value: projectsStore.formMode != nil)
        .background(WindowChromeSetup())
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            checkLongSession()
        }
        .onChange(of: session.selectedProject?.id) { _, _ in
            hasWarnedThisSession = false
        }
        .alert("Still working?", isPresented: $showLongSessionWarning) {
            Button("Yes, keep going") {}
            Button("Pause it") { session.toggleRunPause() }
        } message: {
            Text("\"\(session.selectedProject?.name ?? "")\" has been running a while. Just checking you haven't forgotten about it.")
        }
    }

    private func checkLongSession() {
        guard session.isRunning, !hasWarnedThisSession else { return }
        let elapsed = session.currentElapsed(at: Date())
        let thresholdSeconds = Int(settings.longSessionThresholdHours * 3600)
        if elapsed >= thresholdSeconds {
            hasWarnedThisSession = true
            showLongSessionWarning = true
        }
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
    let history = SessionHistoryStore()
    ContentView(session: WorkSessionState(historyStore: history), historyStore: history)
        .frame(width: 700, height: 560)
}
