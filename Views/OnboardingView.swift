//
//  OnboardingView.swift
//  TaskManager
//
//  Created by Admin on 5/9/2026.
//

import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.06)
                    .ignoresSafeArea()

                VStack(spacing: 28) {
                    Spacer()

                    Text("Welcome to TaskManager")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 18) {
                        onboardingRow(
                            icon: "folder.fill",
                            text: "Add your projects with a priority and a time estimate."
                        )
                        onboardingRow(
                            icon: "shuffle",
                            text: "Tap the picker to get a weighted recommendation — or choose one yourself."
                        )
                        onboardingRow(
                            icon: "chart.bar.fill",
                            text: "Every session you finish quietly builds your real stats over time."
                        )
                    }
                    .frame(maxWidth: geo.size.width - 140)

                    Spacer()

                    LiquidChromeButton(cornerRadius: 22, action: onFinish) {
                        Text("Get Started")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 220, height: 56)
                    }

                    Spacer().frame(height: 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .transition(.opacity)
    }

    private func onboardingRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.orange)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
