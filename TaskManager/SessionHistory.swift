//
//  SessionHistory.swift
//  TaskManager
//
//  Created by Admin on 29/8/2026.
//

import Foundation
import Combine

// Immutable once written. Keeps a projectNameSnapshot so a later
// rename or archive of the project doesn't corrupt old stats.
struct HistoricalSession: Identifiable, Codable {
    let id: UUID
    let projectID: UUID
    let projectNameSnapshot: String
    let startedAt: Date
    let endedAt: Date
    let durationSeconds: Int

    init(
        id: UUID = UUID(),
        projectID: UUID,
        projectNameSnapshot: String,
        startedAt: Date,
        endedAt: Date,
        durationSeconds: Int
    ) {
        self.id = id
        self.projectID = projectID
        self.projectNameSnapshot = projectNameSnapshot
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.durationSeconds = durationSeconds
    }
}

@MainActor
final class SessionHistoryStore: ObservableObject {

    private let filename = "sessions.json"

    @Published var sessions: [HistoricalSession] {
        didSet { persist() }
    }

    init() {
        self.sessions = JSONFileStore.load([HistoricalSession].self, from: filename) ?? []
    }

    // Append-only — nothing ever updates or deletes a historical
    // record once it exists.
    func append(_ session: HistoricalSession) {
        sessions.append(session)
    }

    private func persist() {
        JSONFileStore.save(sessions, to: filename)
    }
}
