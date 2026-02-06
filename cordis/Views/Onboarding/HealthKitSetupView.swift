//
//  HealthKitSetupView.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI

struct HealthKitSetupView: View {
    @Binding var healthKitEnabled: Bool
    var onContinue: () -> Void
    var onSkip: () -> Void

    @StateObject private var healthKit = HealthKitManager.shared
    @State private var isConnecting = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 120, height: 120)

                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 12) {
                Text(String(localized: "onboarding_health_title"))
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(String(localized: "onboarding_health_description"))
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Benefits list
            GlassCard {
                VStack(alignment: .leading, spacing: 16) {
                    benefitRow(icon: "arrow.triangle.2.circlepath", text: String(localized: "onboarding_health_benefit1"))
                    benefitRow(icon: "chart.line.uptrend.xyaxis", text: String(localized: "onboarding_health_benefit2"))
                    benefitRow(icon: "hand.tap.fill", text: String(localized: "onboarding_health_benefit3"))
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 12) {
                GlassButton(
                    String(localized: "onboarding_health_connect"),
                    icon: "heart.fill",
                    style: .success,
                    isLoading: isConnecting
                ) {
                    connectHealthKit()
                }

                Button {
                    onSkip()
                } label: {
                    Text(String(localized: "onboarding_health_skip"))
                        .font(.body.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.vertical, 12)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.green)
                .frame(width: 30)

            Text(text)
                .font(.body)
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    private func connectHealthKit() {
        isConnecting = true
        Task {
            let authorized = await healthKit.requestAuthorization()
            isConnecting = false
            if authorized {
                healthKitEnabled = true
                onContinue()
            }
        }
    }
}

#Preview {
    ZStack {
        AnimatedGlassBackground(colorScheme: .calm)
        HealthKitSetupView(healthKitEnabled: .constant(false), onContinue: {}, onSkip: {})
    }
}
