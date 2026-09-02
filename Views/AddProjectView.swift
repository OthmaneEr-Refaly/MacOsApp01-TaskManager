import SwiftUI

struct AddProjectView: View {
    @ObservedObject var store: ProjectsStore
    @ObservedObject var session: WorkSessionState
    @Binding var selectedTab: AppTab

    @State private var draftName: String
    @State private var draftHours: Double
    @State private var selectedImportance: Bool?
    @State private var selectedUrgency: Bool?

    private var editingProject: ManagedProject? {
        if case .edit(let project) = store.formMode { return project }
        return nil
    }
    private var isEditing: Bool { editingProject != nil }

    // Blocks Complete/Archive on THIS project specifically.
    private var isThisProjectActiveInSession: Bool {
        guard let editingProject else { return false }
        return session.selectedProject?.id == editingProject.id
    }

    // Blocks "Work on This Now" — ANY active session (on any
    // project) blocks starting a new one. One session at a time.
    private var canStartWorkingNow: Bool {
        isEditing && !session.hasProject && editingProject?.status == .active
    }

    init(store: ProjectsStore, session: WorkSessionState, selectedTab: Binding<AppTab>) {
        self.store = store
        self.session = session
        self._selectedTab = selectedTab

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

                    statusGuardMessages(width: geo.size.width - 160)

                    if isEditing && canStartWorkingNow {
                        LiquidChromeButton(cornerRadius: 22, action: workOnThisNow) {
                            Text("Work on This Now")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(width: 220, height: 56)
                        }
                    }

                    actionRow
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .transition(.opacity)
    }

    @ViewBuilder
    private func statusGuardMessages(width: CGFloat) -> some View {
        if isEditing && isThisProjectActiveInSession {
            Text("You're currently working on this project. Finish or discard the session to change its status.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: width)
        } else if isEditing && session.hasProject && !isThisProjectActiveInSession {
            Text("Finish or discard your session on \"\(session.selectedProject?.name ?? "")\" before starting work on a different project.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: width)
        }
    }

    private var actionRow: some View {
        HStack(spacing: 16) {
            if isEditing {
                if editingProject?.status == .active {
                    Button("Archive", action: archive)
                        .buttonStyle(.plain)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .elegantDarkGlow(cornerRadius: 20, glowOpacity: 0)
                        .disabled(isThisProjectActiveInSession)
                        .opacity(isThisProjectActiveInSession ? 0.35 : 1)

                    Button("Complete", action: complete)
                        .buttonStyle(.plain)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.green)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .elegantDarkGlow(cornerRadius: 20, glowOpacity: 0)
                        .disabled(isThisProjectActiveInSession)
                        .opacity(isThisProjectActiveInSession ? 0.35 : 1)
                } else {
                    Button("Reactivate", action: reactivate)
                        .buttonStyle(.plain)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .elegantDarkGlow(cornerRadius: 20, glowOpacity: 0)
                }
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
                quadrant: quadrant,
                status: existing.status
            ))
        } else {
            store.add(ManagedProject(name: draftName, estimatedHours: draftHours, quadrant: quadrant))
        }

        store.formMode = nil
    }

    private func archive() {
        guard let existing = editingProject, !isThisProjectActiveInSession else { return }
        store.archive(existing)
        store.formMode = nil
    }

    private func complete() {
        guard let existing = editingProject, !isThisProjectActiveInSession else { return }
        store.complete(existing)
        store.formMode = nil
    }

    private func reactivate() {
        guard let existing = editingProject else { return }
        store.reactivate(existing)
        store.formMode = nil
    }

    // Bypasses the picker entirely — same effect as accepting a
    // recommendation, just chosen directly by the user.
    private func workOnThisNow() {
        guard let existing = editingProject, !session.hasProject else { return }
        session.select(existing)
        store.formMode = nil
        selectedTab = .home
    }
}
