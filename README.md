# TaskManager — macOS Focus & Work Session Tracker

> **My first ever macOS app.** The UI is fully vibe coded, but every bit of the logic is mine — built with Swift & Xcode.

---

## Screenshots

<p align="center">
  <img src="Assets/Screenshot 2026-09-10 at 14.05.11.png" width="380" alt="Home screen – idle state" />
  <img src="Assets/Screenshot 2026-09-10 at 14.05.28.png" width="380" alt="Home screen – active session" />
</p>
<p align="center">
  <img src="Assets/Screenshot 2026-09-10 at 14.05.35.png" width="380" alt="Projects view" />
  <img src="Assets/Screenshot 2026-09-10 at 14.05.42.png" width="380" alt="Stats view – This Week" />
</p>

---

## What is it?

**SHIFT** is a minimal, dark-themed macOS app designed to help you stay focused and track exactly how much time you spend on each of your projects.

The idea is simple: you have so many projects and you dont know which one to start. What should i do ? you might ask.
Well, this app will help you with that by choosing your next project for you base on how important/urgent that project is and how much time you have left to complete it.

### Core Features

- **🗂 Project Management** — Create and organise projects with an estimated time budget. Each project sits in one of four priority quadrants (inspired by the Eisenhower Matrix), helping you focus on what matters. Projects can be marked as *Active*, *Completed*, *Snoozed*, or *Archived* at any time.

- **⏱ Work Sessions** — A clean session panel on the home screen lets you start, pause, and stop a timed work session for any project. A live timer bar and animated display make it easy to see exactly how long you've been at it without breaking focus.

- **📊 Stats & History** — A weekly bar chart shows your daily output at a glance, backed by a log of recent sessions with timestamps and durations. Sessions are persisted locally so your history survives restarts.

- **🔔 Long-Session Nudge** — The app checks in if a session has been running unusually long (configurable threshold), making sure you haven't accidentally left the timer running.

- **🎛 Intelligent Project Picker** — A scrollable, slot-machine-style picker lets you flick through your active projects quickly to switch context without friction.

- **⚙️ Settings** — Tune the long-session warning threshold and chart display range. A first-run onboarding flow guides new users through the basics.

---

## Tech Stack

| | |
|---|---|
| **Language** | Swift |
| **Framework** | SwiftUI + AppKit (via `NSViewRepresentable`) |
| **Persistence** | JSON flat-file store (custom `JSONFileStore`) |
| **IDE** | Xcode |
| **Platform** | macOS |

---

## Personal Note

This is my **first ever macOS app**. The visual design and UI layout were fully vibe coded — I leaned into what felt right aesthetically and iterated quickly. However, all of the application logic is written by me: the session state machine, project lifecycle management, snooze/expiry handling, duplicate-name resolution, persistence layer, stats aggregation, and the long-session warning system.

Building this taught me a lot about SwiftUI's state management, the AppKit/SwiftUI bridge, and how to structure a small but real macOS application from scratch.

---

*Made with ☕ and a lot of focus sessions.*
