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

                        // Institution
                        institutionSection

                        // Version
                        versionSection
                    }
                    .padding()
                }
            }
            .navigationTitle(String(localized: "about_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common_done")) {
                        dismiss()
                    }
                    .foregroundStyle(.white)
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
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundStyle(.purple)
                    Text(String(localized: "about_credits"))
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 12) {
                    creditRow(
                        name: "Christian Arzaluz",
                        role: String(localized: "about_developed_by")
                    )

                    creditRow(
                        name: "Ubaldo Orozco Camargo",
                        role: String(localized: "about_developed_by")
                    )
                }
            }
        }
    }

    private func creditRow(name: String, role: String) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(name.prefix(1)))
                        .font(.headline)
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white)

                Text(role)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }

    // MARK: - Institution Section

    private var institutionSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "building.columns.fill")
                        .foregroundStyle(.purple)
                    Text(String(localized: "about_institution"))
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.1))
                            .frame(width: 50, height: 50)

                        Image(systemName: "graduationcap.fill")
                            .font(.title2)
                            .foregroundStyle(.purple)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Colegio Walden Dos")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.white)

                        Text("México")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
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
