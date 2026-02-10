//
//  WristGuideView.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI

struct WristGuideView: View {
    @State private var isPulsing = false
    @State private var showFingers = false

    private let skinGradient = LinearGradient(
        colors: [Color(hex: "FFDAB9"), Color(hex: "E8C4A8")],
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        ZStack {
            // Arm illustration (bottom to top: forearm -> wrist -> hand with fingers up)
            VStack(spacing: 0) {
                // Hand (palm up, fingers extending upward)
                PalmUpHandShape()
                    .fill(skinGradient)
                    .frame(width: 140, height: 130)

                // Wrist section (narrower transition)
                RoundedRectangle(cornerRadius: 12)
                    .fill(skinGradient)
                    .frame(width: 90, height: 40)

                // Forearm
                RoundedRectangle(cornerRadius: 20)
                    .fill(skinGradient)
                    .frame(width: 120, height: 160)
            }

            // Pulse point indicator (radial artery - right side of wrist, thumb side)
            ZStack {
                // Outer pulsing ring
                Circle()
                    .stroke(Color.red.opacity(0.3), lineWidth: 3)
                    .frame(width: isPulsing ? 60 : 40, height: isPulsing ? 60 : 40)
                    .opacity(isPulsing ? 0 : 0.8)

                // Middle ring
                Circle()
                    .stroke(Color.red.opacity(0.5), lineWidth: 2)
                    .frame(width: isPulsing ? 45 : 30, height: isPulsing ? 45 : 30)
                    .opacity(isPulsing ? 0.3 : 0.9)

                // Center dot
                Circle()
                    .fill(Color.red)
                    .frame(width: 20, height: 20)
                    .scaleEffect(isPulsing ? 1.2 : 1.0)
            }
            .offset(x: 25, y: 10)

            // Pulse point label
            Text(String(localized: "manual_pulse_point"))
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
                .offset(x: 25, y: 45)

            // Finger indicators (approaching from above toward the pulse point)
            if showFingers {
                HStack(spacing: 8) {
                    ForEach(0..<2, id: \.self) { _ in
                        Capsule()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 20, height: 50)
                            .shadow(color: .black.opacity(0.2), radius: 3)
                    }
                }
                .offset(x: 25, y: -30)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 200, height: 380)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isPulsing = true
            }

            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                showFingers = true
            }
        }
    }
}

// MARK: - Palm Up Hand Shape (fingers extending upward, thumb on right)

struct PalmUpHandShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.width
        let h = rect.height

        // Start at bottom-left of palm (connects to wrist)
        path.move(to: CGPoint(x: w * 0.2, y: h))

        // Left edge of palm up to pinky base
        path.addLine(to: CGPoint(x: w * 0.1, y: h * 0.45))

        // Pinky finger
        path.addQuadCurve(
            to: CGPoint(x: w * 0.12, y: h * 0.1),
            control: CGPoint(x: w * 0.05, y: h * 0.25)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.22, y: h * 0.4),
            control: CGPoint(x: w * 0.2, y: h * 0.1)
        )

        // Ring finger
        path.addQuadCurve(
            to: CGPoint(x: w * 0.28, y: h * 0.05),
            control: CGPoint(x: w * 0.22, y: h * 0.2)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.38, y: h * 0.38),
            control: CGPoint(x: w * 0.38, y: h * 0.05)
        )

        // Middle finger
        path.addQuadCurve(
            to: CGPoint(x: w * 0.44, y: h * 0.0),
            control: CGPoint(x: w * 0.38, y: h * 0.15)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.55, y: h * 0.36),
            control: CGPoint(x: w * 0.55, y: h * 0.0)
        )

        // Index finger
        path.addQuadCurve(
            to: CGPoint(x: w * 0.6, y: h * 0.05),
            control: CGPoint(x: w * 0.55, y: h * 0.15)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.7, y: h * 0.4),
            control: CGPoint(x: w * 0.72, y: h * 0.05)
        )

        // Thumb (extending to the right)
        path.addQuadCurve(
            to: CGPoint(x: w * 0.95, y: h * 0.35),
            control: CGPoint(x: w * 0.85, y: h * 0.3)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.8, y: h * 0.6),
            control: CGPoint(x: w * 1.0, y: h * 0.5)
        )

        // Right edge of palm down to wrist
        path.addLine(to: CGPoint(x: w * 0.8, y: h))

        path.closeSubpath()

        return path
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AnimatedGlassBackground(colorScheme: .calm)

        WristGuideView()
    }
}
