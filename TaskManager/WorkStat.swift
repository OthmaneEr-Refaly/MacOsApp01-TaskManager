import Foundation

struct DailyWorkStat: Identifiable {
    let id = UUID()
    let date: Date
    let hours: Double
}

enum WorkStatsAggregator {

    // Builds the last `days` daily buckets from real session
    // history. A session crossing midnight contributes its real
    // overlap seconds to each calendar day it touches — computed
    // here at query time, never stored pre-split.
    static func aggregate(
        from sessions: [HistoricalSession],
        days: Int = 7,
        calendar: Calendar = .current
    ) -> [DailyWorkStat] {
        let today = calendar.startOfDay(for: Date())
        let dayStarts: [Date] = (0..<days).map { offset in
            calendar.date(byAdding: .day, value: -(days - 1 - offset), to: today)!
        }

        var totals: [Date: Int] = [:]
        for dayStart in dayStarts { totals[dayStart] = 0 }

        for session in sessions {
            for dayStart in dayStarts {
                let seconds = overlapSeconds(of: session, withDayStarting: dayStart, calendar: calendar)
                if seconds > 0 {
                    totals[dayStart, default: 0] += seconds
                }
            }
        }

        return dayStarts.map { dayStart in
            DailyWorkStat(date: dayStart, hours: Double(totals[dayStart] ?? 0) / 3600.0)
        }
    }

    private static func overlapSeconds(
        of session: HistoricalSession,
        withDayStarting dayStart: Date,
        calendar: Calendar
    ) -> Int {
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
        let overlapStart = max(session.startedAt, dayStart)
        let overlapEnd = min(session.endedAt, dayEnd)
        guard overlapEnd > overlapStart else { return 0 }
        return Int(overlapEnd.timeIntervalSince(overlapStart))
    }
}
