import SwiftUI

// MARK: - Work-intent mode, chosen right before spinning. Changes
// how the score weighs priority vs remaining time — this is what
// actually solves "I want something light tonight" properly,
// instead of just tolerating it as noise in the weighting.
enum PickerMode: String, CaseIterable {
    case focus = "Focus"
    case light = "Light"
    case surprise = "Surprise"

    var icon: String {
        switch self {
        case .focus: return "scope"
        case .light: return "leaf.fill"
        case .surprise: return "sparkles"
        }
    }
}

// MARK: - Ruler tick marks (unchanged).
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

// MARK: - Ruler carousel + picker. Now a real state machine:
// idle -> spinning -> recommended (holds until Start or Choose
// Another) -> (Start) hands off to the caller. Locks entirely
// while a session is already active, so it can never silently
// swap the project underneath a running/paused timer.
struct ProjectPickerRuler: View {

    var projects: [ManagedProject]
    var historyStore: SessionHistoryStore
    var hasActiveSession: Bool
    var activeProjectName: String?
    var onStart: (ManagedProject) -> Void = { _ in }

    var itemSpacing: CGFloat = 260
    var visibleRange: Int = 3

    @State private var offset: Double = 0
    @State private var isSpinning = false
    @State private var hasPickedOnce = false
    @State private var reel: [ManagedProject] = []
    @State private var recommendation: ManagedProject? = nil
    @State private var pickerMode: PickerMode = .focus

    // Eliminate-quadrant projects are never auto-recommended —
    // that quadrant means "don't do this," by definition.
    private var eligibleProjects: [ManagedProject] {
        projects.filter { $0.quadrant != .eliminate && $0.status == .active }
    }

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                RulerTicks()
                carousel
                    .frame(height: 90)
                    .clipped()
                RulerTicks(flipped: true)
            }

            controls
        }
    }

    @ViewBuilder
    private var controls: some View {
        if hasActiveSession {
            Text("Currently working on \(activeProjectName ?? "")")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.orange)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 20)
                .frame(width: 280, height: 64)
                .elegantDarkGlow(cornerRadius: 22, glowOpacity: 0)
        } else if let recommendation {
            HStack(spacing: 12) {
                Button(action: reroll) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .elegantDarkGlow(cornerRadius: 22, glowOpacity: 0)
                .disabled(isSpinning)

                LiquidChromeButton(cornerRadius: 22, action: { start(recommendation) }) {
                    Text("Start Working")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 210, height: 64)
                }
                .disabled(isSpinning)
            }
        } else {
            VStack(spacing: 12) {
                modeSelector

                LiquidChromeButton(cornerRadius: 22, action: spin) {
                    Text(eligibleProjects.isEmpty ? "Add a project first" : "What should I work on next?")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 16)
                        .frame(width: 280, height: 64)
                }
                .opacity((isSpinning || eligibleProjects.isEmpty) ? 0.6 : 1)
                .disabled(isSpinning || eligibleProjects.isEmpty)
            }
        }
    }

    private var modeSelector: some View {
        HStack(spacing: 10) {
            ForEach(PickerMode.allCases, id: \.self) { mode in
                Button(action: { pickerMode = mode }) {
                    Image(systemName: mode.icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(pickerMode == mode ? .white : .gray.opacity(0.5))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .elegantDarkGlow(
                    cornerRadius: 16,
                    borderWidth: pickerMode == mode ? 1.5 : 1,
                    glowOpacity: 0
                )
            }
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

    private func trackedSeconds(for project: ManagedProject) -> Int {
        historyStore.sessions
            .filter { $0.projectID == project.id }
            .reduce(0) { $0 + $1.durationSeconds }
    }

    // What's actually left, not what was originally guessed —
    // a project you've already logged 4 of its 5 estimated hours
    // on should score very differently than a fresh 5h project.
    private func remainingHours(for project: ManagedProject) -> Double {
        let tracked = Double(trackedSeconds(for: project)) / 3600.0
        return max(project.estimatedHours - tracked, 0)
    }

    private func score(for project: ManagedProject, mode: PickerMode) -> Double {
        let important = project.quadrant == .doFirst || project.quadrant == .schedule
        let urgent = project.quadrant == .doFirst || project.quadrant == .delegate
        let normalizedRemaining = min(remainingHours(for: project), 12) / 12

        switch mode {
        case .focus:
            // Priority dominates; remaining time barely nudges it.
            return (important ? 5 : 0) + (urgent ? 5 : 0) + (normalizedRemaining * 0.5)
        case .light:
            // Inverted from the default — SHORTER remaining work
            // scores higher, priority still counts but less.
            let shortBonus = (1 - normalizedRemaining) * 3
            return (important ? 2 : 0) + (urgent ? 2 : 0) + shortBonus
        case .surprise:
            // Compressed differences — closer to a genuine coin
            // flip among everything eligible, controlled randomness
            // rather than priority dominating.
            return (important ? 1 : 0) + (urgent ? 1 : 0) + (normalizedRemaining * 0.3)
        }
    }

    private func buildWeightedReel() -> [ManagedProject] {
        var built: [ManagedProject] = []
        for project in eligibleProjects {
            let weight = score(for: project, mode: pickerMode) + 0.5
            let copies = max(1, Int((weight * 3).rounded()))
            built.append(contentsOf: Array(repeating: project, count: copies))
        }
        return built.shuffled()
    }

    // Explicit reroll — discards the current recommendation and
    // spins again. Never happens implicitly.
    private func reroll() {
        recommendation = nil
        spin()
    }

    // Accepting a recommendation hands it to the caller (which
    // starts the actual session) and clears local picker state.
    private func start(_ project: ManagedProject) {
        onStart(project)
        recommendation = nil
    }

    private func spin() {
        guard !isSpinning, !eligibleProjects.isEmpty else { return }
        reel = buildWeightedReel()
        isSpinning = true
        hasPickedOnce = true
        recommendation = nil

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
                // Holds as a recommendation — does NOT commit yet.
                recommendation = projectAt(Int(target))
            }
        }
    }
}
