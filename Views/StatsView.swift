//
//  StatsView.swift
//  TaskManager
//
//  Created by Admin on 24/8/2026.
//

import SwiftUI
import Charts

struct StatsView: View {
    @State private var stats: [DailyWorkStat] = []
    @State private var animateIn = false

    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("This Week")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            Chart(stats) { stat in
                BarMark(
                    x: .value("Day", dayFormatter.string(from: stat.date)),
                    y: .value("Hours", animateIn ? stat.hours : 0),
                    width: .ratio(0.55)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .orange.opacity(0.45)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .cornerRadius(6)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.08))
                    AxisValueLabel().foregroundStyle(Color.gray)
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel().foregroundStyle(Color.gray)
                }
            }
            .frame(height: 260)
        }
        .padding(32)
        .onAppear {
            stats = SampleWorkData.lastSevenDays()
            withAnimation(.spring(response: 0.75, dampingFraction: 0.75).delay(0.1)) {
                animateIn = true
            }
        }
    }
}
