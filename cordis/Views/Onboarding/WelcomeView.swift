//
//  WelcomeView.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI

struct WelcomeView: View {
    var onContinue: () -> Void

    @State private var showContent = false
    @State private var pulseHeart = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Animated heart logo
            ZStack {
                // Pulsing background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.pink.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(pulseHeart ? 1.2 : 0.9)

                // Heart icon
                Image(systemName: "heart.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .pink.opacity(0.5), radius: 20)
                    .scaleEffect(pulseHeart ? 1.1 : 1.0)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 30)

            VStack(spacing: 16) {
                Text(String(localized: "onboarding_welcome_title"))
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(String(localized: "onboarding_welcome_subtitle"))
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)

                Text(String(localized: "onboarding_welcome_description"))
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)

            Spacer()

            GlassButton(
                String(localized: "onboarding_continue"),
                icon: "arrow.right",
                style: .primary
            ) {
                onContinue()
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseHeart = true
            }
        }
    }
}

#Preview {
    ZStack {
        AnimatedGlassBackground(colorScheme: .calm)
        WelcomeView(onContinue: {})
    }
}
