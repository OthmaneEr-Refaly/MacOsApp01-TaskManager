//
//  AppDelegate.swift
//  TaskManager
//
//  Created by Admin on 2/9/2026.
//

import AppKit
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: Timer?

    // Set once from the App struct once the session object exists.
    var session: WorkSessionState? {
        didSet { observeSession() }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "TaskManager"
        statusItem?.button?.target = self
        statusItem?.button?.action = #selector(statusItemClicked)
    }

    private func observeSession() {
        guard let session else { return }

        // React immediately to real state changes (project picked,
        // started, paused, finished)...
        session.$selectedProject
            .combineLatest(session.$isRunning)
            .sink { [weak self] _, _ in
                self?.updateStatusItem()
            }
            .store(in: &cancellables)

        // ...and tick the displayed elapsed time once a second.
        // The underlying value is still timestamp-based (via
        // currentElapsed(at:)) — this timer only refreshes the
        // menu bar text, it isn't the source of truth for time.
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateStatusItem()
        }

        updateStatusItem()
    }

    private func updateStatusItem() {
        guard let session, let project = session.selectedProject else {
            statusItem?.button?.title = "TaskManager"
            return
        }

        let elapsed = session.currentElapsed(at: Date())
        let m = elapsed / 60
        let s = elapsed % 60
        let dot = session.isRunning ? "●" : "○"
        statusItem?.button?.title = " \(dot) \(project.name) \(String(format: "%d:%02d", m, s))"
    }

    @objc private func statusItemClicked() {
        NSApp.activate(ignoringOtherApps: true)
        for window in NSApp.windows {
            window.makeKeyAndOrderFront(nil)
        }
    }
}
