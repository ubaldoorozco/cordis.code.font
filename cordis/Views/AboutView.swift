//
//  AboutView.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGlassBackground(colorScheme: .calm)

                ScrollView {
                    VStack(spacing: 32) {
                        // App Icon and Name
                        appHeader

                        // Description
                        descriptionSection

                        // Credits
                        creditsSection

                        // Version
                        versionSection
                    }
                    .padding()
                    .frame(maxWidth: 700)
                }
            }
            .navigationTitle(String(localized: "about_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common_done")) {
                        dismiss()
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
    }

    // MARK: - App Header

    private var appHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.pink.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)

                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .pink.opacity(0.5), radius: 15)
            }

            Text("CORDIS")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.top, 20)
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        GlassCard {
            Text(String(localized: "about_description"))
                .font(.body)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Credits Section

    private var creditsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundStyle(.purple)
                    Text(String(localized: "about_credits"))
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                creditGroup(
                    title: String(localized: "credits_development"),
                    icon: "chevron.left.forwardslash.chevron.right",
                    names: ["Christian Daniel Arzaluz Tellez", "Ubaldo Orozco Camargo", "Santiago Aragoneses Arizmendii", "Patricio Aguilar Pacheco", "Miguel Ángel Arturo Roldán García", "Hansel Eduardo Ortega Borgues"]
                )

                Divider().overlay(.white.opacity(0.2))

                creditGroup(
                    title: String(localized: "credits_guided_meditations"),
                    icon: "headphones",
                    names: ["Janet Castillo Reyes", "Sarahí Serrano García", "Isabel Alondra Castro Terán"]
                )

                Divider().overlay(.white.opacity(0.2))

                creditGroup(
                    title: "Colegio Walden Dos de México",
                    icon: "building.columns.fill",
                    names: ["Eduardo Hermosillo Fuster"]
                )
            }
        }
    }

    private func creditGroup(title: String, icon: String, names: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(.purple.opacity(0.8))
                    .frame(width: 20)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }

            ForEach(names, id: \.self) { name in
                creditRow(name: name)
            }
        }
    }

    private func creditRow(name: String) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(name.prefix(1)))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                )

            Text(name)
                .font(.body)
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    // MARK: - Version Section

    private var versionSection: some View {
        GlassCard(padding: 12) {
            HStack {
                Text(String(localized: "about_version"))
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
                Text("\(appVersion) (\(buildNumber))")
                    .foregroundStyle(.white)
            }
            .font(.subheadline)
        }
    }
}

#Preview {
    AboutView()
}
