//
//  HistoryView.swift
//  cordis
//
//  ubaldo orozco on 23/12/25
//  Redesigned with glassmorphism
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \StressEntry.timestamp, order: .reverse) private var entries: [StressEntry]
    @Environment(\.modelContext) private var context

    enum RangeFilter: Int, CaseIterable, Identifiable {
        case last7Days = 0
        case lastMonth = 1
        case lastYear = 2
        case all = 3

        var id: Int { rawValue }

        var localizedTitle: String {
            switch self {
            case .last7Days: return String(localized: "history_filter_7days")
            case .lastMonth: return String(localized: "history_filter_30days")
            case .lastYear: return String(localized: "history_filter_year")
            case .all: return String(localized: "history_filter_all")
            }
        }
    }

    @State private var filter: RangeFilter = .last7Days

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGlassBackground(colorScheme: .calm)

                ScrollView {
                    VStack(spacing: 16) {
                        // Filter pills
                        filterSection

                        // Entries
                        if filteredEntries.isEmpty {
                            emptyState
                        } else {
                            entriesList
                        }
                    }
                    .padding()
                    .frame(maxWidth: 700)
                }
            }
            .navigationTitle(String(localized: "history_title"))
            .navigationBarTitleDisplayMode(.large)
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(RangeFilter.allCases) { opt in
                    GlassPillButton(opt.localizedTitle, isSelected: filter == opt) {
                        withAnimation(.spring(duration: 0.3)) {
                            filter = opt
                        }
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        GlassCard {
            VStack(spacing: 16) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 50))
                    .foregroundStyle(.secondary)

                Text(String(localized: "history_empty"))
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
    }

    // MARK: - Entries List

    private var entriesList: some View {
        LazyVStack(spacing: 16) {
            ForEach(weekKeys, id: \.self) { weekStart in
                weekSection(weekStart: weekStart)
            }
        }
    }

    private func weekSection(weekStart: Date) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(weekHeader(for: weekStart))
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))
                .padding(.leading, 4)

            let arr = groupedByWeek[weekStart] ?? []
            ForEach(arr, id: \.id) { entry in
                entryCard(entry: entry, weekEntries: arr)
            }
        }
    }

    private func entryCard(entry: StressEntry, weekEntries: [StressEntry]) -> some View {
        GlassCardAccent(accentColor: entry.color) {
            HStack(spacing: 16) {
                // Level indicator
                Circle()
                    .fill(entry.color)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(localizedStressLevel(entry.stressLevel))
                        .font(.headline)
                        .foregroundStyle(entry.color)

                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(entry.bpm)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        Text("BPM")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(entry.timestamp, format: .dateTime.weekday(.abbreviated))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(entry.timestamp, format: .dateTime.hour().minute())
                        .font(.subheadline.bold())
                }
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                withAnimation {
                    context.delete(entry)
                    do { try context.save() } catch { print("SAVE ERROR (delete):", error) }
                }
            } label: {
                Label(String(localized: "history_delete"), systemImage: "trash")
            }
        }
    }

    // MARK: - Data Processing

    private var filteredEntries: [StressEntry] {
        let now = Date()
        let cal = Calendar.current
        switch filter {
        case .last7Days:
            let from = cal.date(byAdding: .day, value: -6, to: cal.startOfDay(for: now)) ?? now
            return entries.filter { $0.timestamp >= from }
        case .lastMonth:
            let from = cal.date(byAdding: .month, value: -1, to: now) ?? now
            return entries.filter { $0.timestamp >= from }
        case .lastYear:
            let from = cal.date(byAdding: .year, value: -1, to: now) ?? now
            return entries.filter { $0.timestamp >= from }
        case .all:
            return entries
        }
    }

    private var groupedByWeek: [Date: [StressEntry]] {
        Dictionary(grouping: filteredEntries) { startOfWeek(for: $0.timestamp) }
            .mapValues { $0.sorted { $0.timestamp > $1.timestamp } }
    }

    private var weekKeys: [Date] { groupedByWeek.keys.sorted(by: >) }

    private func startOfWeek(for date: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return cal.date(from: comps) ?? cal.startOfDay(for: date)
    }

    private func weekHeader(for weekStart: Date) -> String {
        let cal = Calendar.current
        let weekEnd = cal.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
        let startStr = weekStart.formatted(.dateTime.day().month(.abbreviated))
        let endStr = weekEnd.formatted(.dateTime.day().month(.abbreviated))
        return "\(startStr) – \(endStr)"
    }

    private func localizedStressLevel(_ raw: String) -> String {
        switch raw.lowercased() {
        case "excelente": return String(localized: "stress_excellent")
        case "normal": return String(localized: "stress_normal")
        case "elevado": return String(localized: "stress_elevated")
        case "muy elevado", "arritmia": return String(localized: "stress_very_high")
        case "muy bajo", "paro cardiaco": return String(localized: "stress_very_low")
        default: return raw
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [StressEntry.self, UserStats.self, AppSettings.self], inMemory: true)
}
