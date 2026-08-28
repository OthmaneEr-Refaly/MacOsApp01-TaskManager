import SwiftUI

struct AddProjectView: View {
    @ObservedObject var store: ProjectsStore

    @State private var draftName: String
    @State private var draftHours: Double
    @State private var selectedImportance: Bool?
    @State private var selectedUrgency: Bool?

    private var editingProject: ManagedProject? {
        if case .edit(let project) = store.formMode { return project }
        return nil
    }
    private var isEditing: Bool { editingProject != nil }

    init(store: ProjectsStore) {
        self.store = store

        if case .edit(let project) = store.formMode {
            _draftName = State(initialValue: project.name)
            _draftHours = State(initialValue: project.estimatedHours)
            switch project.quadrant {
            case .doFirst:
                _selectedImportance = State(initialValue: true)
                _selectedUrgency = State(initialValue: true)
            case .schedule:
                _selectedImportance = State(initialValue: true)
                _selectedUrgency = State(initialValue: false)
            case .delegate:
                _selectedImportance = State(initialValue: false)
                _selectedUrgency = State(initialValue: true)
            case .eliminate:
                _selectedImportance = State(initialValue: false)
                _selectedUrgency = State(initialValue: false)
            }
        } else {
            _draftName = State(initialValue: "")
            _draftHours = State(initialValue: 2)
            _selectedImportance = State(initialValue: nil)
            _selectedUrgency = State(initialValue: nil)
        }
    }

    private var canSave: Bool {
        !draftName.trimmingCharacters(in: .whitespaces).isEmpty
            && selectedImportance != nil && selectedUrgency != nil
    }

    var body: some View {
        GeometryReader { geo in
            let crossSize = min(geo.size.width - 100, geo.size.height * 0.72)

            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.06)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    closeButton

                    TextField("Project name", text: $draftName)
                        .textFieldStyle(.plain)
                        .font(.system(size: 26, weight: .heavy))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .frame(maxWidth: geo.size.width - 160)

                    PriorityCross(importance: $selectedImportance, urgency: $selectedUrgency)
                        .frame(width: crossSize, height: crossSize)

                    DurationTickSlider(
                        hours: $draftHours,
                        tickCount: 32,
                        filledTickHeight: 14,
                        unfilledTickHeight: 9,
                        barHeight: 16,
                        readoutFontSize: 15
                    )
                    .frame(width: geo.size.width - 260)

                    HStack(spacing: 16) {
                        if isEditing {
                            Button("Delete", action: delete)
                                .buttonStyle(.plain)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.red)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .elegantDarkGlow(cornerRadius: 20, glowOpacity: 0)
                        }

                        LiquidChromeButton(cornerRadius: 22, action: save) {
                            Text(isEditing ? "Save Changes" : "Save Project")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(width: 200, height: 56)
                        }
                        .opacity(canSave ? 1 : 0.35)
                        .disabled(!canSave)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .transition(.opacity)
    }

    private var closeButton: some View {
        HStack {
            Button(action: { store.formMode = nil }) {
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
        .padding(.top, 30)
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

        if let existing = editingProject {
            store.update(ManagedProject(
                id: existing.id,
                name: draftName,
                estimatedHours: draftHours,
                quadrant: quadrant
            ))
        } else {
            store.add(ManagedProject(name: draftName, estimatedHours: draftHours, quadrant: quadrant))
        }

        store.formMode = nil
    }

    private func delete() {
        guard let existing = editingProject else { return }
        store.delete(existing)
        store.formMode = nil
    }
}
