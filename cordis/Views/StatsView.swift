//
//  StatsView.swift
//  cordis
//
//  ubaldo orozco on 23/12/25
//  Redesigned with glassmorphism
//

import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Binding var selectedTab: Int
    @Query(sort: \StressEntry.timestamp, order: .reverse)
    private var entries: [StressEntry]

    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var showChat = false
    @State private var selectedPeriod: StatsPeriod = .week

    enum StatsPeriod: Int, CaseIterable {
        case week = 0
        case month = 1
        case all = 2

        var localizedTitle: String {
            switch self {
            case .week: return String(localized: "stats_weekly")
            case .month: return String(localized: "stats_monthly")
            case .all: return String(localized: "history_filter_all")
            }
        }
    }

    var filteredEntries: [StressEntry] {
        let now = Date()
        let cal = Calendar.current
        switch selectedPeriod {
        case .week:
            let from = cal.date(byAdding: .day, value: -7, to: now) ?? now
            return entries.filter { $0.timestamp >= from }
        case .month:
            let from = cal.date(byAdding: .month, value: -1, to: now) ?? now
            return entries.filter { $0.timestamp >= from }
        case .all:
            return entries
        }
    }

    var promedio: Double {
        guard !filteredEntries.isEmpty else { return 0 }
        return Double(filteredEntries.map(\.bpm).reduce(0, +)) / Double(filteredEntries.count)
    }

    var minBPM: Int {
        filteredEntries.map(\.bpm).min() ?? 0
    }

    var maxBPM: Int {
        filteredEntries.map(\.bpm).max() ?? 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGlassBackground(colorScheme: .calm)

                ScrollView {
                    VStack(spacing: 20) {
                        // Period selector
                        periodSelector

                        // Average card
                        averageCard

                        // Min/Max cards
                        minMaxCards

                        // Chart
                        chartSection

                        // Chat button
                        chatButton

                        // Total entries
                        totalEntriesCard
                    }
                    .padding()
                    .frame(maxWidth: 700)
                }
            }
            .navigationTitle(String(localized: "stats_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showChat = true
                    } label: {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .sheet(isPresented: $showChat) {
                HealthAssistantView()
            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
    }

    // MARK: - Period Selector

    private var periodSelector: some View {
        HStack(spacing: 12) {
            ForEach(StatsPeriod.allCases, id: \.rawValue) { period in
                GlassPillButton(period.localizedTitle, isSelected: selectedPeriod == period) {
                    withAnimation(.spring(duration: 0.3)) {
                        selectedPeriod = period
                    }
                }
            }
        }
    }

    // MARK: - Average Card

    private var averageCard: some View {
        GlassCardAccent(accentColor: .purple) {
            VStack(spacing: 8) {
                Text(String(localized: "stats_average"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(String(format: "%.0f", promedio))
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                        .animation(.spring(duration: 0.3), value: promedio)

                    Text("BPM")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Min/Max Cards

    private var minMaxCards: some View {
        HStack(spacing: 16) {
            GlassCard {
                VStack(spacing: 8) {
                    Image(systemName: "arrow.down")
                        .foregroundStyle(.green)
                    Text("Min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(minBPM)")
                        .font(.title.bold())
                }
                .frame(maxWidth: .infinity)
            }

            GlassCard {
                VStack(spacing: 8) {
                    Image(systemName: "arrow.up")
                        .foregroundStyle(.red)
                    Text("Max")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(maxBPM)")
                        .font(.title.bold())
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Chart Section

    private var chartSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "stats_bpm_over_time"))
                    .font(.headline)
                    .foregroundStyle(.secondary)

                if filteredEntries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)

                        Text(String(localized: "stats_no_data"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: sizeClass == .regular ? 320 : 200)
                } else {
                    Chart(filteredEntries) { entry in
                        LineMark(
                            x: .value("Date", entry.timestamp),
                            y: .value("BPM", entry.bpm)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))

                        AreaMark(
                            x: .value("Date", entry.timestamp),
                            y: .value("BPM", entry.bpm)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple.opacity(0.3), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        PointMark(
                            x: .value("Date", entry.timestamp),
                            y: .value("BPM", entry.bpm)
                        )
                        .foregroundStyle(entry.color)
                        .symbolSize(30)
                    }
                    .chartYScale(domain: (minBPM - 10)...(maxBPM + 10))
                    .frame(height: sizeClass == .regular ? 320 : 200)
                }
            }
        }
    }

    // MARK: - Chat Button

    private var chatButton: some View {
        GlassButton(String(localized: "stats_chat"), icon: "bubble.left.and.bubble.right.fill", style: .primary) {
            showChat = true
        }
    }

    // MARK: - Total Entries Card

    private var totalEntriesCard: some View {
        Button {
            selectedTab = 1
        } label: {
            GlassCard(padding: 12) {
                HStack {
                    Image(systemName: "list.bullet")
                        .foregroundStyle(.purple)
                    Text(String(localized: "stats_entries"))
                        .font(.subheadline)
                    Spacer()
                    Text("\(entries.count)")
                        .font(.headline)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StatsView(selectedTab: .constant(2))
        .modelContainer(for: [StressEntry.self], inMemory: true)
}
