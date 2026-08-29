import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var historyStore: SessionHistoryStore

    @State private var stats: [DailyWorkStat] = []
    @State private var animateIn = false

    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f
    }()

    private var hasAnyData: Bool {
        stats.contains { $0.hours > 0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("This Week")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            if hasAnyData {
                chart
            } else {
                Text("No work sessions yet — start a timer on Home to see your stats here.")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 60)
            }
        }
        .padding(32)
        .onAppear {
            stats = WorkStatsAggregator.aggregate(from: historyStore.sessions)
            withAnimation(.spring(response: 0.75, dampingFraction: 0.75).delay(0.1)) {
                animateIn = true
            }
        }
    }

    private var chart: some View {
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
}
