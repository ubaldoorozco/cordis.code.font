//
//  OnboardingCompleteView.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI

struct OnboardingCompleteView: View {
    var userName: String
    var onFinish: () -> Void

    @State private var showContent = false
    @State private var showConfetti = false

    private var greeting: String {
        if userName.isEmpty {
            return String(localized: "onboarding_complete_title")
        } else {
            return String(localized: "onboarding_complete_title_name \(userName)")
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                Spacer()

                // Success icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.green.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)

                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 120, height: 120)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(showContent ? 1 : 0.5)
                .opacity(showContent ? 1 : 0)

                VStack(spacing: 12) {
                    Text(greeting)
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(String(localized: "onboarding_complete_subtitle"))
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                Spacer()

                GlassButton(
                    String(localized: "onboarding_complete_button"),
                    icon: "heart.fill",
                    style: .success
                ) {
                    onFinish()
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
            }

            // Confetti overlay
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
        }
    }
}

#Preview {
    ZStack {
        AnimatedGlassBackground(colorScheme: .calm)
        OnboardingCompleteView(userName: "Carlos", onFinish: {})
    }
}
