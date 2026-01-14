//
//  HistoryView.swift
//  cordis
//
//  Extracted by assistant on 23/12/25
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \StressEntry.timestamp, order: .reverse) private var entries: [StressEntry]
    @Environment(\.modelContext) private var context

    enum RangeFilter: String, CaseIterable, Identifiable {
        case last7Days = "Últimos 7 días"
        case lastMonth = "Último mes"
        case lastYear  = "Último año"
        case all       = "Todo"
        var id: String { rawValue }
    }

    @State private var filter: RangeFilter = .last7Days

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Rango", selection: $filter) {
                        ForEach(RangeFilter.allCases) { opt in
                            Text(opt.rawValue).tag(opt)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                ForEach(weekKeys, id: \.self) { weekStart in
                    Section(header: Text(weekHeader(for: weekStart))) {
                        let arr = groupedByWeek[weekStart] ?? []
                        ForEach(arr, id: \.id) { entry in
                            HStack {
                                Circle().fill(entry.color).frame(width: 16, height: 16)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(localizedStressLevel(entry.stressLevel))
                                        .font(.headline)
                                        .foregroundColor(entry.color)
                                    Text("\(entry.bpm) bpm")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(entry.timestamp, format: .dateTime.hour().minute())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete { indexSet in
                            for i in indexSet { context.delete(arr[i]) }
                            do { try context.save() } catch { print("SAVE ERROR (delete):", error) }
                        }
                    }
                }

                if filteredEntries.isEmpty {
                    Section {
                        Text("No hay registros en este rango.")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Historial")
        }
    }

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
        return "Semana \(startStr) – \(endStr)"
    }

    private func localizedStressLevel(_ raw: String) -> String {
        switch raw.lowercased() {
        case "excelente": return "Excelente"
        case "normal": return "Normal"
        case "elevado": return "Elevado"
        case "arritmia": return "Arritmia"
        case "paro cardiaco": return "Paro cardiaco"
        default: return raw
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [StressEntry.self, UserStats.self, AppSettings.self], inMemory: true)
}
