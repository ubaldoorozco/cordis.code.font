//
//  SettingsView.swift
//  cordis
//
// created by ubaldo orozoco camargo  on 23/12/25
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var settingsArr: [AppSettings]

    @State private var selectedTheme = 0
    @State private var selectedAge = 2

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Apariencia
                Section(header: Text("Apariencia")) {
                    Picker("Modo", selection: $selectedTheme) {
                        Text("Sistema").tag(0)
                        Text("Claro").tag(1)
                        Text("Oscuro").tag(2)
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: - Edad
                Section(header: Text("Edad")) {
                    Picker("Rango", selection: $selectedAge) {
                        Text("4 a 7 años").tag(0)
                        Text("8 a 12 años").tag(1)
                        Text("13 a 16 años").tag(2)
                    }
                    .pickerStyle(.segmented)

                    let t = StressEntry.thresholds(for: selectedAge)
                    Text("Ritmo esperado: \(t.min) – \(t.max) bpm")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                // MARK: - Créditos
                Section(header: Text("Créditos")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Programación")
                            .font(.headline)

                        Text("Ubaldo Orozco Camargo")
                            .font(.subheadline)

                        Divider()

                        Text("Diseño")
                            .font(.headline)

                        Text("Patricio Aguilar Pacheco")
                        Text("Miguel Ángel Roldán García")
                        Text("Hansel Eduardo Ortega Borges")
                        Text("Santiago Aragoneses Arismendi")
                    }
                    .padding(.vertical, 6)
                }

                // MARK: - Nota
                Section {
                    Text("CORDIS es un proyecto educativo enfocado en el monitoreo y análisis del ritmo cardíaco con relacion al dia dia .")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Configuración")
        }
        .onAppear {
            ensureSettingsExists()
            if let s = settingsArr.first {
                selectedTheme = s.themeMode
                selectedAge = s.ageGroup
            }
        }
        .onChange(of: selectedTheme) { _ in save() }
        .onChange(of: selectedAge) { _ in save() }
    }

    // MARK: - Persistencia
    private func ensureSettingsExists() {
        if settingsArr.isEmpty {
            context.insert(AppSettings())
            try? context.save()
        }
    }

    private func save() {
        ensureSettingsExists()
        guard let s = settingsArr.first else { return }
        s.themeMode = selectedTheme
        s.ageGroup = selectedAge
        try? context.save()
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [StressEntry.self, UserStats.self, AppSettings.self], inMemory: true)
}

