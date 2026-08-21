import SwiftUI

// MARK: - Everything you'd want to tweak lives here.
struct WindowDesign {
    var backgroundColor: Color = Color(red: 0.05, green: 0.05, blue: 0.06)
    var windowCornerRadius: CGFloat = 12

    static let `default` = WindowDesign()
}

struct ContentView: View {

    var design: WindowDesign = .default

    var body: some View {
        GeometryReader { geo in
            ZStack {
                design.backgroundColor
                    .ignoresSafeArea()

                ProjectPickerRuler()
                    .frame(width: geo.size.width - 80)
                    // same "slightly above middle" spot as before
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.42)
            }
        }
        .ignoresSafeArea()
        .overlay(AnimatedGlowBorder(cornerRadius: design.windowCornerRadius))
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



