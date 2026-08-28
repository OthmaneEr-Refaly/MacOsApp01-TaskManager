import SwiftUI

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
// Now driven by real projects from ProjectsStore, weighted by a
// score combining importance + urgency + estimated time.
struct ProjectPickerRuler: View {

    var projects: [ManagedProject]
    var onSelect: (ManagedProject) -> Void = { _ in }

    var itemSpacing: CGFloat = 260
    var visibleRange: Int = 3

    @State private var offset: Double = 0
    @State private var isSpinning = false
    @State private var hasPickedOnce = false
    @State private var reel: [ManagedProject] = []

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                RulerTicks()
                carousel
                    .frame(height: 90)
                    .clipped()
                RulerTicks(flipped: true)
            }

            LiquidChromeButton(cornerRadius: 22, action: spin) {
                Text(projects.isEmpty ? "Add a project first" : "What should I work on next?")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 16)
                    .frame(width: 280, height: 64)
            }
            .opacity((isSpinning || projects.isEmpty) ? 0.6 : 1)
            .disabled(isSpinning || projects.isEmpty)
        }
    }

    private var carousel: some View {
        GeometryReader { geo in
            Group {
                if hasPickedOnce, !reel.isEmpty {
                    ZStack {
                        ForEach(-visibleRange...visibleRange, id: \.self) { k in
                            let index = Int(offset.rounded()) + k
                            let project = projectAt(index)
                            let distance = abs(Double(index) - offset)
                            let scale = max(0.7, 1 - distance * 0.16)
                            let opacity = max(0.25, 1 - distance * 0.32)

                            Text(project.name.uppercased())
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
                } else {
                    Text("Tap below to pick a project")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.gray.opacity(0.4))
                        .frame(width: geo.size.width, height: geo.size.height)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: hasPickedOnce)
        }
    }

    private func projectAt(_ index: Int) -> ManagedProject {
        guard !reel.isEmpty else {
            return ManagedProject(name: "—", estimatedHours: 0, quadrant: .eliminate)
        }
        let count = reel.count
        let wrapped = ((index % count) + count) % count
        return reel[wrapped]
    }

    // MARK: - Weighted scoring
    // Do First / Schedule both count as "important"; Do First /
    // Delegate both count as "urgent". Time favors LONGER tasks,
    // normalized against a 12h ceiling (matches DurationTickSlider's max).
    private func score(for project: ManagedProject) -> Double {
        let important = project.quadrant == .doFirst || project.quadrant == .schedule
        let urgent = project.quadrant == .doFirst || project.quadrant == .delegate
        let timeFactor = min(project.estimatedHours, 12) / 12
        return (important ? 3 : 0) + (urgent ? 3 : 0) + (timeFactor * 2)
    }

    // Builds a reel where higher-scoring projects appear more times —
    // proportional odds, not a forced outcome. The existing physics
    // then runs completely untouched against this reel.
    private func buildWeightedReel() -> [ManagedProject] {
        var built: [ManagedProject] = []
        for project in projects {
            let weight = score(for: project) + 0.5 // floor so nothing has zero chance
            let copies = max(1, Int((weight * 3).rounded()))
            built.append(contentsOf: Array(repeating: project, count: copies))
        }
        return built.shuffled()
    }

    private func spin() {
        guard !isSpinning, !projects.isEmpty else { return }
        reel = buildWeightedReel()
        isSpinning = true
        hasPickedOnce = true

        Task {
            var velocity = Double.random(in: 14...20)
            let decayRate = 1.6
            var lastTime = CFAbsoluteTimeGetCurrent()

            while abs(velocity) > 0.08 {
                let now = CFAbsoluteTimeGetCurrent()
                let dt = now - lastTime
                lastTime = now
                velocity *= exp(-decayRate * dt)
                await MainActor.run { offset += velocity * dt }
                try? await Task.sleep(nanoseconds: 16_000_000)
            }

            let target = offset.rounded()
            await MainActor.run {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                    offset = target
                }
            }
            try? await Task.sleep(nanoseconds: 300_000_000)
            await MainActor.run {
                isSpinning = false
                onSelect(projectAt(Int(target)))
            }
        }
    }
}
