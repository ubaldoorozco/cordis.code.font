//
//  DisclaimerView.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI

struct DisclaimerView: View {
    @Binding var hasAccepted: Bool
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 100, height: 100)

                Image(systemName: "exclamationmark.shield.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 12) {
                Text(String(localized: "onboarding_disclaimer_title"))
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(String(localized: "onboarding_disclaimer_text"))
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            // Acceptance checkbox
            GlassCard {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        hasAccepted.toggle()
                    }
                } label: {
                    HStack(alignment: .top, spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(hasAccepted ? Color.green : Color.white.opacity(0.5), lineWidth: 2)
                                .frame(width: 28, height: 28)

                            if hasAccepted {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.green)
                                    .frame(width: 28, height: 28)

                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }

                        Text(String(localized: "onboarding_disclaimer_checkbox"))
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)

            GlassButton(
                String(localized: "onboarding_continue"),
                icon: "arrow.right",
                style: hasAccepted ? .primary : .secondary
            ) {
                if hasAccepted {
                    onContinue()
                }
            }
            .disabled(!hasAccepted)
            .opacity(hasAccepted ? 1 : 0.6)
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    ZStack {
        AnimatedGlassBackground(colorScheme: .calm)
        DisclaimerView(hasAccepted: .constant(false), onContinue: {})
    }
}
