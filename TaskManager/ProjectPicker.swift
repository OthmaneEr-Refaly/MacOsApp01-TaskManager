import SwiftUI

// MARK: - Placeholder model — real "what's next" logic comes later.
struct Project: Identifiable {
    let id = UUID()
    let name: String
}

// MARK: - Ruler tick marks (matches the reference: small ticks,
// taller every 5th, tallest at dead center).
struct RulerTicks: View {
    var totalLines: Int = 60
    var flipped: Bool = false

    var body: some View {
        GeometryReader { geo in
            let spacing = geo.size.width / CGFloat(max(totalLines - 1, 1))
            ZStack(alignment: .topLeading) {
                ForEach(0..<totalLines, id: \.self) { i in
                    let isCenter = i == totalLines / 2
                    let isFifth = i % 5 == 0
                    let height: CGFloat = isCenter ? 26 : (isFifth ? 14 : 10)
                    let color: Color = (isCenter || isFifth) ? .white : .white.opacity(0.35)

                    Rectangle()
                        .fill(color)
                        .frame(width: 1.5, height: height)
                        .position(
                            x: CGFloat(i) * spacing,
                            y: flipped ? geo.size.height - height / 2 : height / 2
                        )
                }
            }
        }
        .frame(height: 28)
    }
}

// MARK: - Ruler carousel + "What should I work on next?" trigger.
// Click spins the ruler right-to-left with real deceleration
// physics, then settles on a project — the settle IS the reveal.
struct ProjectPickerRuler: View {

    var projects: [Project] = [
        Project(name: "MyCel"),
        Project(name: "CodeVisualizer"),
        Project(name: "BackendRoadmap"),
        Project(name: "NvimExtensions"),
        Project(name: "Planora"),
        Project(name: "one API at a timeh")
    ]

    var itemSpacing: CGFloat = 260
    var visibleRange: Int = 3

    // Continuous position in "item index" space — not necessarily
    // a whole number while spinning.
    @State private var offset: Double = 0
    @State private var isSpinning = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                RulerTicks()
                carousel
                    .frame(height: 90)
                    .clipped()
                RulerTicks(flipped: true)
            }

            Button(action: spin) {
                Text("What should I work on next?")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 16)
                    .frame(width: 280, height: 64)
            }
            .buttonStyle(.plain)
            .elegantDarkGlow(cornerRadius: 22)
            .overlay(AnimatedGlowBorder(cornerRadius: 22, speed: isSpinning ? 1.4 : 6))
            .disabled(isSpinning)
        }
    }

    private var carousel: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(-visibleRange...visibleRange, id: \.self) { k in
                    let index = Int(offset.rounded()) + k
                    let project = projectAt(index)
                    let distance = abs(Double(index) - offset)
                    let scale = max(0.7, 1 - distance * 0.16)
                    let opacity = max(0.25, 1 - distance * 0.32)

                    Text(project.name)
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundStyle(.white)
                        .opacity(opacity)
                        .scaleEffect(scale)
                        .lineLimit(1)
                        .position(
                            x: geo.size.width / 2 + CGFloat(Double(index) - offset) * itemSpacing,
                            y: geo.size.height / 2
                        )
                }
            }
        }
    }

    // Infinite wrap via modulo — no need for the triplicated-array
    // trick from the React version, SwiftUI can just index forever.
    private func projectAt(_ index: Int) -> Project {
        let count = projects.count
        let wrapped = ((index % count) + count) % count
        return projects[wrapped]
    }

    private func spin() {
        guard !isSpinning, !projects.isEmpty else { return }
        isSpinning = true

        Task {
            // Randomized initial speed so it doesn't land on the
            // same relative item every time.
            var velocity = Double.random(in: 14...20)
            let decayRate = 1.6 // higher = stops sooner
            var lastTime = CFAbsoluteTimeGetCurrent()

            // Continuous exponential-decay physics loop — true
            // "flick and slow down" motion, not stepped.
            while abs(velocity) > 0.08 {
                let now = CFAbsoluteTimeGetCurrent()
                let dt = now - lastTime
                lastTime = now
                velocity *= exp(-decayRate * dt)
                await MainActor.run { offset += velocity * dt }
                try? await Task.sleep(nanoseconds: 16_000_000) // ~60fps
            }

            // Clean snap to the nearest whole item to land exactly centered.
            let target = offset.rounded()
            await MainActor.run {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                    offset = target
                }
            }
            try? await Task.sleep(nanoseconds: 300_000_000)
            await MainActor.run { isSpinning = false }
        }
    }
}
