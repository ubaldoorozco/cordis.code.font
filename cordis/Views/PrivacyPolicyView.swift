//
//  PrivacyPolicyView.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGlassBackground(colorScheme: .calm)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "privacy_title"))
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)

                            Text(String(localized: "privacy_last_updated"))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .padding(.bottom, 8)

                        // Section 1: Data Collection
                        policySection(
                            title: String(localized: "privacy_section_data_title"),
                            icon: "doc.text.fill",
                            content: [
                                String(localized: "privacy_data_heart_rate"),
                                String(localized: "privacy_data_name"),
                                String(localized: "privacy_data_age"),
                                String(localized: "privacy_data_history")
                            ]
                        )

                        // Section 2: How We Use Data
                        policySection(
                            title: String(localized: "privacy_section_usage_title"),
                            icon: "chart.bar.fill",
                            content: [
                                String(localized: "privacy_usage_stats"),
                                String(localized: "privacy_usage_wellness"),
                                String(localized: "privacy_usage_personalize"),
                                String(localized: "privacy_usage_no_share")
                            ]
                        )

                        // Section 3: Data Storage
                        policySection(
                            title: String(localized: "privacy_section_storage_title"),
                            icon: "lock.shield.fill",
                            content: [
                                String(localized: "privacy_storage_local"),
                                String(localized: "privacy_storage_swiftdata"),
                                String(localized: "privacy_storage_cloudkit")
                            ]
                        )

                        // Section 4: HealthKit
                        policySection(
                            title: String(localized: "privacy_section_healthkit_title"),
                            icon: "heart.text.square.fill",
                            content: [
                                String(localized: "privacy_healthkit_read"),
                                String(localized: "privacy_healthkit_no_write"),
                                String(localized: "privacy_healthkit_revoke")
                            ]
                        )

                        // Section 5: Your Rights
                        policySection(
                            title: String(localized: "privacy_section_rights_title"),
                            icon: "person.badge.shield.checkmark.fill",
                            content: [
                                String(localized: "privacy_rights_delete"),
                                String(localized: "privacy_rights_disable"),
                                String(localized: "privacy_rights_manual")
                            ]
                        )

                        // Section 6: Contact
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundStyle(.purple)
                                    Text(String(localized: "privacy_section_contact_title"))
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                }

                                Text(String(localized: "privacy_contact_text"))
                                    .font(.body)
                                    .foregroundStyle(.white.opacity(0.85))
                            }
                        }

                        // Disclaimer
                        GlassCard(padding: 12) {
                            HStack(spacing: 10) {
                                Image(systemName: "info.circle")
                                    .foregroundStyle(.secondary)
                                Text(String(localized: "medical_disclaimer"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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

    private func policySection(title: String, icon: String, content: [String]) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(.purple)
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(content, id: \.self) { item in
                        HStack(alignment: .top, spacing: 10) {
                            Circle()
                                .fill(.purple)
                                .frame(width: 6, height: 6)
                                .padding(.top, 7)

                            Text(item)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.85))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PrivacyPolicyView()
}
