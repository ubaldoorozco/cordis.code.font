//
//  MedicalInfoView.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI

struct MedicalInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSection: InfoSection = .ranges

    enum InfoSection: String, CaseIterable {
        case ranges = "ranges"
        case factors = "factors"
        case warning = "warning"
        case sources = "sources"

        var icon: String {
            switch self {
            case .ranges: return "heart.text.square"
            case .factors: return "list.bullet.clipboard"
            case .warning: return "exclamationmark.triangle"
            case .sources: return "book"
            }
        }

        var localizedTitle: String {
            switch self {
            case .ranges: return String(localized: "medical_section_ranges")
            case .factors: return String(localized: "medical_section_factors")
            case .warning: return String(localized: "medical_section_warning")
            case .sources: return String(localized: "medical_section_sources")
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGlassBackground(colorScheme: .calm)

                ScrollView {
                    VStack(spacing: 20) {
                        // Disclaimer banner
                        disclaimerBanner

                        // Section picker
                        sectionPicker

                        // Content
                        Group {
                            switch selectedSection {
                            case .ranges:
                                rangesSection
                            case .factors:
                                factorsSection
                            case .warning:
                                warningSection
                            case .sources:
                                sourcesSection
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                    .padding()
                }
            }
            .navigationTitle(String(localized: "medical_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.primary.opacity(0.6))
                    }
                }
            }
        }
    }

    // MARK: - Disclaimer Banner

    private var disclaimerBanner: some View {
        GlassCardDanger {
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.red)

                Text(String(localized: "medical_disclaimer"))
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
        }
    }

    // MARK: - Section Picker

    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(InfoSection.allCases, id: \.self) { section in
                    GlassPillButton(
                        section.localizedTitle,
                        icon: section.icon,
                        isSelected: selectedSection == section
                    ) {
                        withAnimation(.spring(duration: 0.3)) {
                            selectedSection = section
                        }
                    }
                }
            }
        }
    }

    // MARK: - Heart Rate Ranges Section

    private var rangesSection: some View {
        VStack(spacing: 16) {
            GlassCard {
                VStack(alignment: .leading, spacing: 16) {
                    Label(String(localized: "medical_ranges_title"), systemImage: "heart.text.square")
                        .font(.headline)
                        .foregroundStyle(.purple)

                    Text(String(localized: "medical_ranges_description"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Divider()

                    // Age groups
                    ForEach(ageRanges, id: \.age) { range in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(range.age)
                                    .font(.subheadline.bold())
                                Text(range.source)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(range.bpm)
                                .font(.system(.title3, design: .rounded).bold())
                                .foregroundStyle(.purple)
                        }
                        .padding(.vertical, 8)

                        if range.age != ageRanges.last?.age {
                            Divider()
                        }
                    }
                }
            }

            // Visual chart
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label(String(localized: "medical_visual_guide"), systemImage: "chart.bar")
                        .font(.headline)
                        .foregroundStyle(.purple)

                    ForEach(ageRanges, id: \.age) { range in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(range.age)
                                .font(.caption)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.2))

                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(
                                            LinearGradient(
                                                colors: [.green, .yellow, .orange],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geo.size.width * range.widthFactor)
                                }
                            }
                            .frame(height: 20)

                            HStack {
                                Text("\(range.min)")
                                Spacer()
                                Text("\(range.max)")
                            }
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    // MARK: - Factors Section

    private var factorsSection: some View {
        VStack(spacing: 16) {
            // Factors that increase HR
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label(String(localized: "medical_factors_increase"), systemImage: "arrow.up.heart")
                        .font(.headline)
                        .foregroundStyle(.orange)

                    ForEach(increasingFactors, id: \.self) { factor in
                        factorRow(factor, color: .orange)
                    }
                }
            }

            // Factors that decrease HR
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label(String(localized: "medical_factors_decrease"), systemImage: "arrow.down.heart")
                        .font(.headline)
                        .foregroundStyle(.green)

                    ForEach(decreasingFactors, id: \.self) { factor in
                        factorRow(factor, color: .green)
                    }
                }
            }
        }
    }

    private func factorRow(_ text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(text)
                .font(.subheadline)
        }
    }

    // MARK: - Warning Section

    private var warningSection: some View {
        VStack(spacing: 16) {
            GlassCardDanger {
                VStack(alignment: .leading, spacing: 16) {
                    Label(String(localized: "medical_seek_help"), systemImage: "cross.case")
                        .font(.headline)
                        .foregroundStyle(.red)

                    Text(String(localized: "medical_seek_help_description"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Divider()

                    ForEach(warningSymptoms, id: \.self) { symptom in
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.red)

                            Text(symptom)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

}
    }

    // MARK: - Sources Section

    private var sourcesSection: some View {
        VStack(spacing: 16) {
            GlassCard {
                VStack(alignment: .leading, spacing: 16) {
                    Label(String(localized: "medical_sources_title"), systemImage: "book")
                        .font(.headline)
                        .foregroundStyle(.purple)

                    Text(String(localized: "medical_sources_description"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Divider()

                    ForEach(sources, id: \.name) { source in
                        sourceRow(source)

                        if source.name != sources.last?.name {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private func sourceRow(_ source: MedicalSource) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(source.name)
                .font(.subheadline.bold())

            Text(source.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let url = URL(string: source.url) {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Text(source.url)
                            .lineLimit(1)
                        Image(systemName: "arrow.up.right.square")
                    }
                    .font(.caption)
                    .foregroundStyle(.purple)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Data

    private struct AgeRange {
        let age: String
        let bpm: String
        let min: Int
        let max: Int
        let source: String

        var widthFactor: CGFloat {
            CGFloat(max - 40) / 100.0
        }
    }

    private var ageRanges: [AgeRange] {
        [
            AgeRange(age: String(localized: "age_13_17"), bpm: "60-100 BPM", min: 60, max: 100, source: "AHA, Mayo Clinic, CDC/NCHS"),
            AgeRange(age: String(localized: "age_18_35"), bpm: "60-100 BPM", min: 60, max: 100, source: "AHA, Mayo Clinic, CDC/NCHS"),
            AgeRange(age: String(localized: "age_36_59"), bpm: "60-100 BPM", min: 60, max: 100, source: "AHA, Mayo Clinic, CDC/NCHS"),
            AgeRange(age: String(localized: "age_60_99"), bpm: "60-100 BPM", min: 60, max: 100, source: "AHA, Mayo Clinic, CDC/NCHS")
        ]
    }

    private var increasingFactors: [String] {
        [
            String(localized: "factor_exercise"),
            String(localized: "factor_stress"),
            String(localized: "factor_caffeine"),
            String(localized: "factor_dehydration"),
            String(localized: "factor_fever"),
            String(localized: "factor_medications")
        ]
    }

    private var decreasingFactors: [String] {
        [
            String(localized: "factor_sleep"),
            String(localized: "factor_breathing"),
            String(localized: "factor_meditation"),
            String(localized: "factor_fitness"),
            String(localized: "factor_cold")
        ]
    }

    private var warningSymptoms: [String] {
        [
            String(localized: "warning_chest_pain"),
            String(localized: "warning_breathing"),
            String(localized: "warning_fainting"),
            String(localized: "warning_irregular"),
            String(localized: "warning_extreme_bpm")
        ]
    }

    private struct MedicalSource {
        let name: String
        let description: String
        let url: String
    }

    private var sources: [MedicalSource] {
        [
            MedicalSource(
                name: "American Heart Association (AHA)",
                description: String(localized: "source_aha_description"),
                url: "https://www.heart.org/en/health-topics/high-blood-pressure/the-facts-about-high-blood-pressure/all-about-heart-rate-pulse"
            ),
            MedicalSource(
                name: "Mayo Clinic",
                description: String(localized: "source_mayo_description"),
                url: "https://www.mayoclinic.org/healthy-lifestyle/fitness/expert-answers/heart-rate/faq-20057979"
            ),
            MedicalSource(
                name: "CDC / NCHS",
                description: String(localized: "source_cdc_description"),
                url: "https://www.cdc.gov/nchs/data/nhsr/nhsr041.pdf"
            ),
            MedicalSource(
                name: "Cleveland Clinic",
                description: String(localized: "source_cleveland_description"),
                url: "https://my.clevelandclinic.org/health/diagnostics/heart-rate"
            ),
            MedicalSource(
                name: "NCBI / NIH",
                description: String(localized: "source_ncbi_description"),
                url: "https://www.ncbi.nlm.nih.gov/books/NBK593193/table/ch1survey.T.normal_heart_rate_by_age/"
            ),
            MedicalSource(
                name: "PubMed",
                description: String(localized: "source_pubmed_description"),
                url: "https://pubmed.ncbi.nlm.nih.gov/21905522/"
            )
        ]
    }
}

// MARK: - Preview

#Preview {
    MedicalInfoView()
}
