import SwiftUI

enum PriorityQuadrant: String, CaseIterable, Identifiable, Codable {
    case doFirst = "Do First"
    case schedule = "Schedule"
    case delegate = "Delegate"
    case eliminate = "Eliminate"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .doFirst: return "Urgent & Important"
        case .schedule: return "Important, Not Urgent"
        case .delegate: return "Urgent, Not Important"
        case .eliminate: return "Neither"
        }
    }

    var color: Color {
        switch self {
        case .doFirst: return .red
        case .schedule: return .blue
        case .delegate: return .yellow
        case .eliminate: return .gray
        }
    }
}

// NOTE: the grid-of-4-cells UI below is no longer used anywhere
// (replaced by PriorityCross) — left in place only because
// PriorityQuadrant above is still a live dependency elsewhere.
struct PriorityMatrix: View {
    @Binding var selected: PriorityQuadrant?

    private let rows: [[PriorityQuadrant]] = [
        [.doFirst, .schedule],
        [.delegate, .eliminate]
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<2, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(rows[row]) { quadrant in
                        cell(quadrant)
                    }
                }
            }
        }
    }

    private func cell(_ quadrant: PriorityQuadrant) -> some View {
        let isSelected = selected == quadrant

        return VStack(spacing: 4) {
            Text(quadrant.rawValue)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isSelected ? .orange : .white)
            Text(quadrant.subtitle)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, minHeight: 64)
        .elegantDarkGlow(
            cornerRadius: 14,
            borderWidth: isSelected ? 2 : 1,
            glowOpacity: 0
        )
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .onTapGesture { selected = quadrant }
    }
}
