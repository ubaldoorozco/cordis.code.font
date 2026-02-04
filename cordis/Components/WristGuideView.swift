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

    var body: some View {
        ZStack {
            // Wrist illustration
            VStack(spacing: 0) {
                // Forearm
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FFDAB9"), Color(hex: "E8C4A8")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 120, height: 200)

                // Hand (simplified)
                HandShape()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FFDAB9"), Color(hex: "E8C4A8")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 140, height: 100)
            }

            // Pulse point indicator
            VStack {
                Spacer()
                    .frame(height: 140)

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
                .offset(x: -25, y: 0)

                Spacer()
            }

            // Finger indicators
            if showFingers {
                VStack {
                    Spacer()
                        .frame(height: 100)

                    HStack(spacing: 8) {
                        // Two fingers
                        ForEach(0..<2, id: \.self) { _ in
                            Capsule()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 20, height: 50)
                                .shadow(color: .black.opacity(0.2), radius: 3)
                        }
                    }
                    .offset(x: -25, y: 40)
                    .transition(.scale.combined(with: .opacity))

                    Spacer()
                }
            }
        }
        .frame(width: 200, height: 350)
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

// MARK: - Hand Shape

struct HandShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.width
        let h = rect.height

        // Palm base
        path.move(to: CGPoint(x: w * 0.1, y: 0))
        path.addLine(to: CGPoint(x: w * 0.9, y: 0))

        // Thumb side
        path.addQuadCurve(
            to: CGPoint(x: w * 0.95, y: h * 0.3),
            control: CGPoint(x: w * 0.95, y: h * 0.1)
        )

        // Thumb
        path.addQuadCurve(
            to: CGPoint(x: w * 0.8, y: h * 0.5),
            control: CGPoint(x: w * 1.0, y: h * 0.5)
        )

        // Bottom of hand
        path.addQuadCurve(
            to: CGPoint(x: w * 0.2, y: h * 0.5),
            control: CGPoint(x: w * 0.5, y: h * 0.6)
        )

        // Pinky side
        path.addQuadCurve(
            to: CGPoint(x: w * 0.1, y: 0),
            control: CGPoint(x: w * 0.05, y: h * 0.2)
        )

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
