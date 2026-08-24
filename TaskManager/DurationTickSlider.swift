//
//  DurationTickSlider.swift
//  TaskManager
//
//  Created by Admin on 23/8/2026.
//

import SwiftUI

struct DurationTickSlider: View {
    @Binding var hours: Double
    var maxHours: Double = 12
    var step: Double = 0.5

    private let tickCount = 48

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            tickBar
            Text(formatted(hours))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)
        }
    }

    private var tickBar: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 5
            let tickWidth = max(2, (geo.size.width - CGFloat(tickCount - 1) * spacing) / CGFloat(tickCount))
            let filledTicks = Int((hours / maxHours) * Double(tickCount))

            HStack(spacing: spacing) {
                ForEach(0..<tickCount, id: \.self) { i in
                    let isFilled = i < filledTicks
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            isFilled
                                ? AnyShapeStyle(
                                    LinearGradient(colors: [.orange, .orange.opacity(0.6)],
                                                   startPoint: .top, endPoint: .bottom)
                                  )
                                : AnyShapeStyle(Color.white.opacity(0.15))
                        )
                        .frame(width: tickWidth, height: isFilled ? 26 : 16)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let fraction = min(max(value.location.x / geo.size.width, 0), 1)
                        let raw = fraction * maxHours
                        hours = (raw / step).rounded() * step
                    }
            )
        }
        .frame(height: 30)
    }

    private func formatted(_ h: Double) -> String {
        h == h.rounded() ? "\(Int(h))h" : String(format: "%.1fh", h)
    }
}
