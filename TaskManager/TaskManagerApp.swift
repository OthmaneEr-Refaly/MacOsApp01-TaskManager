import SwiftUI

@main
struct StartWorkingApp: App {

    // Window size — change freely.
    private let minWidth: CGFloat = 500
    private let idealWidth: CGFloat = 700
    private let maxWidth: CGFloat = 900

    private let minHeight: CGFloat = 400
    private let idealHeight: CGFloat = 560
    private let maxHeight: CGFloat = 720

    var body: some Scene {
        WindowGroup {
            ContentView(design: .default)
                .frame(
                    minWidth: minWidth,
                    idealWidth: idealWidth,
                    maxWidth: maxWidth,
                    minHeight: minHeight,
                    idealHeight: idealHeight,
                    maxHeight: maxHeight
                )
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
