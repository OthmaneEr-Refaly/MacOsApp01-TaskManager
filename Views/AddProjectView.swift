import SwiftUI

struct AddProjectView: View {
    @ObservedObject var store: ProjectsStore

    @State private var draftName = ""
    @State private var draftHours: Double = 2
    @State private var selectedImportance: Bool? = nil
    @State private var selectedUrgency: Bool? = nil

    private var canSave: Bool {
        !draftName.trimmingCharacters(in: .whitespaces).isEmpty
            && selectedImportance != nil && selectedUrgency != nil
    }

    var body: some View {
        GeometryReader { geo in
            // Sized off the same width budget the duration slider uses,
            // so the two feel proportionate instead of the cross looking
            // tiny next to it.
            let crossSize = min(geo.size.width - 160, geo.size.height * 0.6)

            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.06)
                    .ignoresSafeArea()

                VStack(spacing: 26) {
                    closeButton

                    TextField("Project name", text: $draftName)
                        .textFieldStyle(.plain)
                        .font(.system(size: 30, weight: .heavy))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .frame(maxWidth: geo.size.width - 160)

                    DurationTickSlider(hours: $draftHours)
                        .frame(width: geo.size.width - 200)

                    PriorityCross(importance: $selectedImportance, urgency: $selectedUrgency)
                        .frame(width: crossSize, height: crossSize)

                    LiquidChromeButton(cornerRadius: 22, action: save) {
                        Text("Save Project")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 200, height: 56)
                    }
                    .opacity(canSave ? 1 : 0.35)
                    .disabled(!canSave)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .transition(.opacity)
    }

    private var closeButton: some View {
        HStack {
            Button(action: { store.isAdding = false }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
            .elegantDarkGlow(cornerRadius: 17, glowOpacity: 0)
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.top, 34)
    }

    private func save() {
        guard canSave, let importance = selectedImportance, let urgency = selectedUrgency else { return }

        let quadrant: PriorityQuadrant
        switch (importance, urgency) {
        case (true, true): quadrant = .doFirst
        case (true, false): quadrant = .schedule
        case (false, true): quadrant = .delegate
        case (false, false): quadrant = .eliminate
        }

        store.add(ManagedProject(name: draftName, estimatedHours: draftHours, quadrant: quadrant))

        draftName = ""
        draftHours = 2
        selectedImportance = nil
        selectedUrgency = nil
        store.isAdding = false
    }
}
