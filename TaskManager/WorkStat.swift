//
//  WorkStat.swift
//  TaskManager
//
//  Created by Admin on 24/8/2026.
//

import Foundation

struct DailyWorkStat: Identifiable {
    let id = UUID()
    let date: Date
    let hours: Double
}

// Placeholder data — real session-logging comes later. This just
// lets us build and judge the chart's look now.
enum SampleWorkData {
    static func lastSevenDays() -> [DailyWorkStat] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sampleHours: [Double] = [2.5, 4.0, 1.0, 5.5, 3.0, 0.5, 6.0] // oldest -> today

        return sampleHours.enumerated().map { index, hours in
            let dayOffset = -(sampleHours.count - 1 - index)
            let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
            return DailyWorkStat(date: date, hours: hours)
        }
    }
}
