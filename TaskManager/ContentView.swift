import SwiftUI

// MARK: - Everything you'd want to tweak lives here.
struct WindowDesign {
    var backgroundColor: Color = Color(red: 0.05, green: 0.05, blue: 0.06)
    var windowCornerRadius: CGFloat = 12

    static let `default` = WindowDesign()
}

struct ContentView: View {

    var design: WindowDesign = .default

    @StateObject private var session = WorkSessionState()
    @StateObject private var projectsStore = ProjectsStore()
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack {
            design.backgroundColor
                .ignoresSafeArea()

            Group {
                switch selectedTab {
                case .home:
                    HomeView(session: session)
                case .projects:
                    ProjectsView(store: projectsStore)
                case .stats:
                    Text("Charts coming soon")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

            // Full-screen takeover — sits above the tab bar too,
            // so it genuinely covers the whole window while adding.
            if projectsStore.isAdding {
                AddProjectView(store: projectsStore)
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.25), value: projectsStore.isAdding)
        .background(WindowChromeSetup())
    }
}

// MARK: - Transparent titlebar, native buttons kept, window opaque.
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
