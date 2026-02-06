//
//  ThemeSetupView.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI

struct ThemeSetupView: View {
    @Binding var selectedTheme: Int
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 100, height: 100)

                Image(systemName: "paintbrush.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 12) {
                Text(String(localized: "onboarding_theme_title"))
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }

            // Theme options
            VStack(spacing: 16) {
                themeOption(
                    tag: 0,
                    icon: "gear",
                    title: String(localized: "onboarding_theme_system"),
                    colors: [.gray, .gray.opacity(0.7)]
                )

                themeOption(
                    tag: 1,
                    icon: "sun.max.fill",
                    title: String(localized: "onboarding_theme_light"),
                    colors: [.yellow, .orange]
                )

                themeOption(
                    tag: 2,
                    icon: "moon.fill",
                    title: String(localized: "onboarding_theme_dark"),
                    colors: [.indigo, .purple]
                )
            }
            .padding(.horizontal, 24)

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
        }
    }

    private func themeOption(tag: Int, icon: String, title: String, colors: [Color]) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedTheme = tag
            }
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(.white)
                }

                Text(title)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white)

                Spacer()

                ZStack {
                    Circle()
                        .stroke(selectedTheme == tag ? Color.purple : Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 28, height: 28)

                    if selectedTheme == tag {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 18, height: 18)
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        selectedTheme == tag ? Color.purple.opacity(0.5) : Color.white.opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
    }
}

#Preview {
    ZStack {
        AnimatedGlassBackground(colorScheme: .calm)
        ThemeSetupView(selectedTheme: .constant(0), onContinue: {})
    }
}
