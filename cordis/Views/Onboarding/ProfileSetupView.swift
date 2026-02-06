//
//  ProfileSetupView.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI

struct ProfileSetupView: View {
    @Binding var userName: String
    @Binding var selectedAgeGroup: Int
    var onContinue: () -> Void

    @FocusState private var isNameFocused: Bool

    private let ageGroups = [
        (0, "4-7", String(localized: "age_4_7")),
        (1, "8-12", String(localized: "age_8_12")),
        (2, "13-16", String(localized: "age_13_16")),
        (3, "17-21", String(localized: "age_17_21"))
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer()
                    .frame(height: 40)

                // Icon
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 100, height: 100)

                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 8) {
                    Text(String(localized: "onboarding_profile_title"))
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }

                // Name input
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "onboarding_profile_name"))
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.9))

                        TextField("", text: $userName)
                            .textFieldStyle(.plain)
                            .font(.title3)
                            .foregroundStyle(.white)
                            .padding()
                            .background(.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .focused($isNameFocused)
                            #if os(iOS)
                            .textInputAutocapitalization(.words)
                            #endif
                            .autocorrectionDisabled()
                    }
                }
                .padding(.horizontal, 24)

                // Age group selector
                GlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(String(localized: "onboarding_profile_age"))
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.9))

                        VStack(spacing: 8) {
                            ForEach(ageGroups, id: \.0) { group in
                                ageGroupButton(tag: group.0, label: group.2)
                            }
                        }

                        Text(String(localized: "onboarding_profile_age_explanation"))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
                    .frame(height: 20)

                GlassButton(
                    String(localized: "onboarding_continue"),
                    icon: "arrow.right",
                    style: .primary
                ) {
                    isNameFocused = false
                    onContinue()
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func ageGroupButton(tag: Int, label: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedAgeGroup = tag
            }
        } label: {
            HStack {
                Text(label)
                    .font(.body.weight(.medium))
                    .foregroundStyle(selectedAgeGroup == tag ? .white : .white.opacity(0.8))

                Spacer()

                if selectedAgeGroup == tag {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                }
            }
            .padding()
            .background(selectedAgeGroup == tag ? Color.purple.opacity(0.6) : Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    ZStack {
        AnimatedGlassBackground(colorScheme: .calm)
        ProfileSetupView(
            userName: .constant(""),
            selectedAgeGroup: .constant(2),
            onContinue: {}
        )
    }
}
