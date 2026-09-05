//
//  SettingsView.swift
//  TaskManager
//
//  Created by Admin on 5/9/2026.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var projectsStore: ProjectsStore
    @ObservedObject var historyStore: SessionHistoryStore

    @State private var showClearConfirm = false

    private let thresholdOptions: [Double] = [1, 2, 4, 8]
    private let chartDayOptions: [Int] = [7, 14, 30]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text("Settings")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                section(title: "Long-Session Warning") {
                    Text("Nudge me after:")
                        .font(.system(size: 13))
                        .foregroundStyle(.gray)
                    optionRow(
                        options: thresholdOptions,
                        selected: settings.longSessionThresholdHours,
                        label: { "\(Int($0))h" }
                    ) { value in
                        settings.longSessionThresholdHours = value
                    }
                }

                section(title: "Stats Chart Range") {
                    Text("Show the last:")
                        .font(.system(size: 13))
                        .foregroundStyle(.gray)
                    optionRow(
                        options: chartDayOptions.map { Double($0) },
                        selected: Double(settings.chartDays),
                        label: { "\(Int($0))d" }
                    ) { value in
                        settings.chartDays = Int(value)
                    }
                }

                section(title: "Data") {
                    Button("Clear All Data", action: { showClearConfirm = true })
                        .buttonStyle(.plain)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .elegantDarkGlow(cornerRadius: 20, glowOpacity: 0)
                        .confirmationDialog(
                            "Delete all projects and session history? This can't be undone.",
                            isPresented: $showClearConfirm,
                            titleVisibility: .visible
                        ) {
                            Button("Delete Everything", role: .destructive) {
                                projectsStore.projects = []
                                historyStore.sessions = []
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                }
            }
            .padding(32)
        }
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
            content()
        }
    }

    private func optionRow(
        options: [Double],
        selected: Double,
        label: @escaping (Double) -> String,
        onSelect: @escaping (Double) -> Void
    ) -> some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                Button(action: { onSelect(option) }) {
                    Text(label(option))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(selected == option ? .white : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .elegantDarkGlow(
                    cornerRadius: 14,
                    borderWidth: selected == option ? 1.5 : 1,
                    glowOpacity: 0
                )
            }
        }
    }
}
