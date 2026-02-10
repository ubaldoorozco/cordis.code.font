//
//  AnimatedGlassBackground.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI

struct AnimatedGlassBackground: View {
    var colorScheme: BackgroundColorScheme
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var animateOrbs = false

    enum BackgroundColorScheme {
        case calm       // Purple/Indigo - default
        case stress     // Red/Orange - elevated stress
        case success    // Green/Teal - excellent
        case neutral    // Gray/Blue - neutral state

        func colors(for appearance: ColorScheme) -> [Color] {
            if appearance == .light {
                switch self {
                case .calm:
                    return [
                        Color(red: 0.75, green: 0.65, blue: 0.92),
                        Color(red: 0.68, green: 0.7, blue: 0.95),
                        Color(red: 0.62, green: 0.75, blue: 0.97)
                    ]
                case .stress:
                    return [
                        Color(red: 0.95, green: 0.65, blue: 0.68),
                        Color(red: 0.97, green: 0.7, blue: 0.72),
                        Color(red: 0.92, green: 0.62, blue: 0.78)
                    ]
                case .success:
                    return [
                        Color(red: 0.6, green: 0.88, blue: 0.82),
                        Color(red: 0.65, green: 0.9, blue: 0.85),
                        Color(red: 0.6, green: 0.82, blue: 0.92)
                    ]
                case .neutral:
                    return [
                        Color(red: 0.78, green: 0.78, blue: 0.84),
                        Color(red: 0.82, green: 0.82, blue: 0.88),
                        Color(red: 0.78, green: 0.82, blue: 0.88)
                    ]
                }
            }
            switch self {
            case .calm:
                return [
                    Color(red: 0.4, green: 0.2, blue: 0.6),
                    Color(red: 0.3, green: 0.3, blue: 0.7),
                    Color(red: 0.2, green: 0.4, blue: 0.8)
                ]
            case .stress:
                return [
                    Color(red: 0.8, green: 0.2, blue: 0.3),
                    Color(red: 0.9, green: 0.3, blue: 0.4),
                    Color(red: 0.7, green: 0.2, blue: 0.5)
                ]
            case .success:
                return [
                    Color(red: 0.2, green: 0.6, blue: 0.5),
                    Color(red: 0.3, green: 0.7, blue: 0.6),
                    Color(red: 0.2, green: 0.5, blue: 0.7)
                ]
            case .neutral:
                return [
                    Color(red: 0.3, green: 0.3, blue: 0.4),
                    Color(red: 0.4, green: 0.4, blue: 0.5),
                    Color(red: 0.3, green: 0.4, blue: 0.5)
                ]
            }
        }

        func orbColors(for appearance: ColorScheme) -> [Color] {
            if appearance == .light {
                switch self {
                case .calm:
                    return [.purple.opacity(0.3), .indigo.opacity(0.25), .blue.opacity(0.2)]
                case .stress:
                    return [.red.opacity(0.3), .orange.opacity(0.25), .pink.opacity(0.2)]
                case .success:
                    return [.green.opacity(0.3), .teal.opacity(0.25), .mint.opacity(0.2)]
                case .neutral:
                    return [.gray.opacity(0.2), .blue.opacity(0.15), .indigo.opacity(0.15)]
                }
            }
            switch self {
            case .calm:
                return [.purple.opacity(0.6), .indigo.opacity(0.5), .blue.opacity(0.4)]
            case .stress:
                return [.red.opacity(0.6), .orange.opacity(0.5), .pink.opacity(0.4)]
            case .success:
                return [.green.opacity(0.6), .teal.opacity(0.5), .mint.opacity(0.4)]
            case .neutral:
                return [.gray.opacity(0.4), .blue.opacity(0.3), .indigo.opacity(0.3)]
            }
        }
    }

    init(colorScheme: BackgroundColorScheme = .calm) {
        self.colorScheme = colorScheme
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base gradient
                LinearGradient(
                    colors: colorScheme.colors(for: systemColorScheme),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Animated orbs
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(colorScheme.orbColors(for: systemColorScheme)[index])
                        .frame(width: orbSize(for: index, in: geometry.size),
                               height: orbSize(for: index, in: geometry.size))
                        .blur(radius: 60 + CGFloat(index * 20))
                        .offset(orbOffset(for: index, in: geometry.size, animated: animateOrbs))
                        .animation(
                            Animation
                                .easeInOut(duration: Double(8 + index * 2))
                                .repeatForever(autoreverses: true),
                            value: animateOrbs
                        )
                }

                // Subtle noise overlay for texture
                Rectangle()
                    .fill(.ultraThinMaterial.opacity(0.1))
            }
            .ignoresSafeArea()
        }
        .onAppear {
            animateOrbs = true
        }
    }

    private func orbSize(for index: Int, in size: CGSize) -> CGFloat {
        let baseSize = min(size.width, size.height) * 0.6
        return baseSize + CGFloat(index * 50)
    }

    private func orbOffset(for index: Int, in size: CGSize, animated: Bool) -> CGSize {
        let multiplier: CGFloat = animated ? 1 : -1

        switch index {
        case 0:
            return CGSize(
                width: multiplier * size.width * 0.2,
                height: multiplier * -size.height * 0.15
            )
        case 1:
            return CGSize(
                width: multiplier * -size.width * 0.25,
                height: multiplier * size.height * 0.2
            )
        default:
            return CGSize(
                width: multiplier * size.width * 0.1,
                height: multiplier * size.height * 0.25
            )
        }
    }
}

// MARK: - Simpler Static Background

struct GlassBackground: View {
    var colors: [Color]

    init(colors: [Color] = [.purple, .indigo, .blue]) {
        self.colors = colors
    }

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Pulsing Heart Background

struct PulsingHeartBackground: View {
    var bpm: Int
    @State private var isPulsing = false

    var pulseInterval: Double {
        60.0 / Double(max(bpm, 40))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base gradient
                LinearGradient(
                    colors: [.purple.opacity(0.8), .indigo.opacity(0.7), .blue.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Pulsing heart glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.pink.opacity(0.4), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.5
                        )
                    )
                    .scaleEffect(isPulsing ? 1.2 : 0.8)
                    .animation(
                        Animation
                            .easeInOut(duration: pulseInterval / 2)
                            .repeatForever(autoreverses: true),
                        value: isPulsing
                    )
            }
            .ignoresSafeArea()
        }
        .onAppear {
            isPulsing = true
        }
        .onChange(of: bpm) { _, _ in
            // Reset animation when BPM changes
            isPulsing = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPulsing = true
            }
        }
    }
}

// MARK: - Preview

#Preview("Animated Calm") {
    AnimatedGlassBackground(colorScheme: .calm)
}

#Preview("Animated Stress") {
    AnimatedGlassBackground(colorScheme: .stress)
}

#Preview("Animated Success") {
    AnimatedGlassBackground(colorScheme: .success)
}

#Preview("Pulsing Heart") {
    PulsingHeartBackground(bpm: 72)
}
