//
//  GlassCard.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat
    var padding: CGFloat

    init(
        cornerRadius: CGFloat = 20,
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.padding = padding
    }

    var body: some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [.primary.opacity(0.2), .primary.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Variations

struct GlassCardAccent<Content: View>: View {
    let content: Content
    var accentColor: Color
    var cornerRadius: CGFloat

    init(
        accentColor: Color = .purple,
        cornerRadius: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.accentColor = accentColor
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .background(accentColor.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: accentColor.opacity(0.2), radius: 15, y: 8)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [accentColor.opacity(0.5), accentColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
    }
}

struct GlassCardDanger<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat

    init(
        cornerRadius: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .background(Color.red.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .red.opacity(0.2), radius: 15, y: 8)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [.red.opacity(0.5), .red.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(
            colors: [.purple, .indigo, .blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: 20) {
            GlassCard {
                VStack(alignment: .leading) {
                    Text("Glass Card")
                        .font(.headline)
                    Text("Standard glassmorphism effect")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GlassCardAccent(accentColor: .green) {
                VStack(alignment: .leading) {
                    Text("Accent Card")
                        .font(.headline)
                    Text("With green accent color")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GlassCardDanger {
                VStack(alignment: .leading) {
                    Text("Danger Card")
                        .font(.headline)
                    Text("For warnings and alerts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
}
