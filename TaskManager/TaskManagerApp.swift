import SwiftUI

@main
struct TaskManagerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @StateObject private var session: WorkSessionState
    @StateObject private var historyStore: SessionHistoryStore

    private let minWidth: CGFloat = 500
    private let idealWidth: CGFloat = 700
    private let maxWidth: CGFloat = 900

    private let minHeight: CGFloat = 400
    private let idealHeight: CGFloat = 560
    private let maxHeight: CGFloat = 720

    init() {
        let history = SessionHistoryStore()
        _historyStore = StateObject(wrappedValue: history)
        _session = StateObject(wrappedValue: WorkSessionState(historyStore: history))
    }

    var body: some Scene {
        WindowGroup {
            ContentView(session: session, historyStore: historyStore)
                .frame(
                    minWidth: minWidth,
                    idealWidth: idealWidth,
                    maxWidth: maxWidth,
                    minHeight: minHeight,
                    idealHeight: idealHeight,
                    maxHeight: maxHeight
                )
                .onAppear {
                    appDelegate.session = session
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
