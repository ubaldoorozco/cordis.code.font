//
//  GlassButton.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI

struct GlassButton: View {
    let title: String
    var icon: String?
    var style: GlassButtonStyle
    var isLoading: Bool
    var action: () -> Void

    enum GlassButtonStyle {
        case primary
        case secondary
        case danger
        case success

        var gradientColors: [Color] {
            switch self {
            case .primary:
                return [Color.purple.opacity(0.8), Color.indigo.opacity(0.8)]
            case .secondary:
                return [Color.gray.opacity(0.3), Color.gray.opacity(0.2)]
            case .danger:
                return [Color.red.opacity(0.8), Color.pink.opacity(0.8)]
            case .success:
                return [Color.green.opacity(0.8), Color.teal.opacity(0.8)]
            }
        }

        var foregroundColor: Color {
            switch self {
            case .secondary:
                return .primary
            default:
                return .white
            }
        }
    }

    init(
        _ title: String,
        icon: String? = nil,
        style: GlassButtonStyle = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }

                Text(title)
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(style.foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(
                    colors: style.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(.ultraThinMaterial.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: style.gradientColors[0].opacity(0.3), radius: 8, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1)
    }
}

// MARK: - Icon-only Button

struct GlassIconButton: View {
    let icon: String
    var size: CGFloat
    var style: GlassButton.GlassButtonStyle
    var action: () -> Void

    init(
        _ icon: String,
        size: CGFloat = 44,
        style: GlassButton.GlassButtonStyle = .secondary,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(style.foregroundColor)
                .frame(width: size, height: size)
                .background(
                    LinearGradient(
                        colors: style.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(.ultraThinMaterial.opacity(0.3))
                .clipShape(Circle())
                .shadow(color: style.gradientColors[0].opacity(0.3), radius: 6, y: 3)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        }
    }
}

// MARK: - Small Pill Button

struct GlassPillButton: View {
    let title: String
    var icon: String?
    var isSelected: Bool
    var action: () -> Void

    init(
        _ title: String,
        icon: String? = nil,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption.weight(.semibold))
                }
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    LinearGradient(
                        colors: [.purple.opacity(0.8), .indigo.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    Color.clear
                }
            }
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: isSelected
                                ? [.white.opacity(0.4), .white.opacity(0.1)]
                                : [.gray.opacity(0.3), .gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
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
            GlassButton("Primary Button", icon: "heart.fill", style: .primary) {}

            GlassButton("Secondary Button", icon: "gear", style: .secondary) {}

            GlassButton("Danger Button", icon: "exclamationmark.triangle.fill", style: .danger) {}

            GlassButton("Success Button", icon: "checkmark.circle.fill", style: .success) {}

            GlassButton("Loading...", style: .primary, isLoading: true) {}

            HStack(spacing: 12) {
                GlassIconButton("heart.fill", style: .danger) {}
                GlassIconButton("gear", style: .secondary) {}
                GlassIconButton("plus", style: .primary) {}
            }

            HStack(spacing: 8) {
                GlassPillButton("7 Days", isSelected: true) {}
                GlassPillButton("30 Days", isSelected: false) {}
                GlassPillButton("All", isSelected: false) {}
            }
        }
        .padding()
    }
}
