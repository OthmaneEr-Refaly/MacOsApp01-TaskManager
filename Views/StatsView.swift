import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var historyStore: SessionHistoryStore
    var chartDays: Int = 7

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

    private var sortedSessions: [HistoricalSession] {
        historyStore.sessions.sorted { $0.startedAt > $1.startedAt }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(chartDays == 7 ? "This Week" : "Last \(chartDays) Days")
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

                if !sortedSessions.isEmpty {
                    Text("Recent Sessions")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.top, 8)

                    VStack(spacing: 10) {
                        ForEach(sortedSessions.prefix(20)) { session in
                            sessionRow(session)
                        }
                    }
                }
            }
            .padding(32)
        }
        .onAppear {
            stats = WorkStatsAggregator.aggregate(from: historyStore.sessions, days: chartDays)
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

    private func sessionRow(_ session: HistoricalSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.projectNameSnapshot)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(dateLabel(session.startedAt))
                    .font(.system(size: 11))
                    .foregroundStyle(.gray)
            }
            Spacer()
            Text(durationLabel(session.durationSeconds))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.orange)
        }
        .padding(14)
        .elegantDarkGlow(cornerRadius: 12, glowOpacity: 0)
    }

    private func dateLabel(_ date: Date) -> String {
        let calendar = Calendar.current
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"

        if calendar.isDateInToday(date) {
            return "Today, \(timeFormatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday, \(timeFormatter.string(from: date))"
        } else {
            let df = DateFormatter()
            df.dateFormat = "MMM d, h:mm a"
            return df.string(from: date)
        }
    }

    private func durationLabel(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }
}
