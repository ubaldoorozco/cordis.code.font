//
//  StatsView.swift
//  cordis
//
//  Extracted by assistant on 23/12/25
//

import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query(sort: \StressEntry.timestamp, order: .reverse) private var entries: [StressEntry]

    var promedio: Double {
        guard !entries.isEmpty else { return 0 }
        return Double(entries.map(\.bpm).reduce(0, +)) / Double(entries.count)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Promedio: \(String(format: "%.1f", promedio)) bpm")
                        .font(.largeTitle).bold()
                        .foregroundColor(.orange)

                    if entries.isEmpty {
                        Text("No hay datos todavía")
                            .foregroundColor(.secondary)
                    } else {
                        Chart(entries) {
                            LineMark(
                                x: .value("Fecha", $0.timestamp),
                                y: .value("BPM", $0.bpm)
                            )
                        }
                        .frame(height: 250)
                    }
                }
                .padding()
            }
            .navigationTitle("Estadísticas")
        }
    }
}
