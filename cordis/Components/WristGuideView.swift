//
//  WristGuideView.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI

struct WristGuideView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        VStack(spacing: 12) {
            // Real photograph of correct finger placement on radial artery
            Image("RadialPulseGuide")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 10)
                .frame(maxWidth: 300)

            // Pulse point label
            Text(String(localized: "manual_pulse_point"))
                .font(.caption)
                .foregroundStyle(.secondary)

            // Attribution (CC BY 4.0)
            Text(String(localized: "wrist_guide_attribution"))
                .font(.caption2)
                .foregroundStyle(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .scaleEffect(sizeClass == .regular ? 1.15 : 1.0)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AnimatedGlassBackground(colorScheme: .calm)

        WristGuideView()
    }
}
