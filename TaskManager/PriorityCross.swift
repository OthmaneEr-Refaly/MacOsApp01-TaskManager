import SwiftUI

// MARK: - Full rectangle framed in ruler ticks, with a ticked "+"
// running through the exact center. Selection happens by tapping
// ONE of the 4 quadrants the cross divides the rectangle into —
// that single tap sets BOTH importance and urgency at once. The
// 4 edge labels are purely visual (bold when their axis matches
// the current selection) — they have no tap behavior of their own.
struct PriorityCross: View {
    @Binding var importance: Bool? // true = important, false = just for fun
    @Binding var urgency: Bool?    // true = urgent, false = later

    private let tickSpacing: CGFloat = 14
    private let tickInset: CGFloat = 10

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Quadrant tap zones (drawn first = underneath the ticks/labels)
                quadrant(importanceValue: true, urgencyValue: false)  // top-left
                    .frame(width: w / 2, height: h / 2)
                    .position(x: w / 4, y: h / 4)

                quadrant(importanceValue: true, urgencyValue: true)   // top-right
                    .frame(width: w / 2, height: h / 2)
                    .position(x: 3 * w / 4, y: h / 4)

                quadrant(importanceValue: false, urgencyValue: false) // bottom-left
                    .frame(width: w / 2, height: h / 2)
                    .position(x: w / 4, y: 3 * h / 4)

                quadrant(importanceValue: false, urgencyValue: true)  // bottom-right
                    .frame(width: w / 2, height: h / 2)
                    .position(x: 3 * w / 4, y: 3 * h / 4)

                tickFrame(w: w, h: h)
                    .allowsHitTesting(false)

                Text("IMPORTANT")
                    .edgeLabelStyle(isSelected: importance == true)
                    .position(x: w / 2, y: 20)
                Text("JUST FOR FUN")
                    .edgeLabelStyle(isSelected: importance == false)
                    .position(x: w / 2, y: h - 20)
                Text("LATER")
                    .edgeLabelStyle(isSelected: urgency == false)
                    .position(x: 46, y: h / 2)
                Text("URGENT")
                    .edgeLabelStyle(isSelected: urgency == true)
                    .position(x: w - 46, y: h / 2)
            }
        }
    }

    private func quadrant(importanceValue: Bool, urgencyValue: Bool) -> some View {
        let isSelected = importance == importanceValue && urgency == urgencyValue
        return Rectangle()
            .fill(isSelected ? Color.white.opacity(0.06) : Color.clear)
            .contentShape(Rectangle())
            .onTapGesture {
                importance = importanceValue
                urgency = urgencyValue
            }
    }

    // Rectangle outline, ticks along all 4 edges, AND a ticked
    // cross through the exact center.
    private func tickFrame(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)

            // Perimeter ticks
            ticksAlong(length: w, isHorizontal: true).position(x: w / 2, y: tickInset)
            ticksAlong(length: w, isHorizontal: true).position(x: w / 2, y: h - tickInset)
            ticksAlong(length: h, isHorizontal: false).position(x: tickInset, y: h / 2)
            ticksAlong(length: h, isHorizontal: false).position(x: w - tickInset, y: h / 2)

            // Center cross — solid line + ticks along both arms
            Rectangle().fill(Color.white.opacity(0.15)).frame(width: w, height: 1)
                .position(x: w / 2, y: h / 2)
            Rectangle().fill(Color.white.opacity(0.15)).frame(width: 1, height: h)
                .position(x: w / 2, y: h / 2)
            ticksAlong(length: w, isHorizontal: true).position(x: w / 2, y: h / 2)
            ticksAlong(length: h, isHorizontal: false).position(x: w / 2, y: h / 2)
        }
    }

    private func ticksAlong(length: CGFloat, isHorizontal: Bool) -> some View {
        let count = max(Int(length / tickSpacing), 2)
        return ZStack {
            ForEach(0..<count, id: \.self) { i in
                let isMajor = i % 5 == 0
                let tickLen: CGFloat = isMajor ? 10 : 6
                let pos = CGFloat(i) * (length / CGFloat(count - 1)) - length / 2

                Rectangle()
                    .fill(Color.white.opacity(isMajor ? 0.5 : 0.2))
                    .frame(
                        width: isHorizontal ? 1.2 : tickLen,
                        height: isHorizontal ? tickLen : 1.2
                    )
                    .offset(
                        x: isHorizontal ? pos : 0,
                        y: isHorizontal ? 0 : pos
                    )
            }
        }
    }
}

private extension Text {
    func edgeLabelStyle(isSelected: Bool) -> some View {
        self.font(.system(size: 12, weight: .heavy))
            .foregroundStyle(isSelected ? .white : .gray.opacity(0.4))
    }
}
