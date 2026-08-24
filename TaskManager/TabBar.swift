import SwiftUI

enum AppTab: CaseIterable {
    case home, projects, stats

    var icon: String {
        switch self {
        case .home: return "shuffle"
        case .projects: return "folder.fill"
        case .stats: return "chart.bar.fill"
        }
    }
}

struct TabBar: View {
    @Binding var selected: AppTab

    var body: some View {
        HStack(spacing: 10) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                TabBarButton(icon: tab.icon, isActive: selected == tab) {
                    selected = tab
                }
            }
        }
    }
}

private struct TabBarButton: View {
    let icon: String
    let isActive: Bool
    let action: () -> Void

    private let size: CGFloat = 34

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isActive ? .white : .gray.opacity(0.5))
                .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        // Flat — active tab is shown by icon color only.
        .elegantDarkGlow(cornerRadius: size / 2, glowOpacity: 0)
    }
}
