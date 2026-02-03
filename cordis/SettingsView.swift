//
//  SettingsView.swift
//  cordis
//
// created by ubaldo orozoco camargo  on 23/12/25
//


import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var settingsArr: [AppSettings]
    @Query(sort: \ChatMessage.timestamp, order: .reverse) private var chatMessages: [ChatMessage]

    @State private var selectedTheme: Int = 0
    @State private var selectedAgeGroup: Int = 3
    @State private var preferredName: String = ""

    // ✅ nuevas configs
    @State private var objective: Int = 0
    @State private var reminderEnabled: Bool = false
    @State private var reminderTime: Date = Date()
    @State private var saveChatHistory: Bool = true

    var body: some View {
        NavigationStack {
            Form {

                Section(header: Text("Perfil")) {
                    TextField("Tu nombre (para el chat)", text: $preferredName)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()

                    Text("El asistente te llamará por este nombre.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section(header: Text("Objetivo")) {
                    Picker("Mi objetivo", selection: $objective) {
                        Text("Calmarme / bajar ritmo").tag(0)
                        Text("Dormir mejor").tag(1)
                        Text("Mejorar hábitos").tag(2)
                        Text("Rendimiento (escuela)").tag(3)
                    }
                    .pickerStyle(.navigationLink)

                    Text("El chat prioriza consejos según tu objetivo.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section(header: Text("Recordatorio diario")) {
                    Toggle("Activar recordatorio", isOn: $reminderEnabled)

                    DatePicker("Hora", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .disabled(!reminderEnabled)

                    Text("Te manda una notificación diaria para registrar tu BPM.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section(header: Text("Privacidad")) {
                    Toggle("Guardar historial del chat", isOn: $saveChatHistory)

                    Text("Si lo apagas, el chat no guarda mensajes y se borran los anteriores.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section(header: Text("Apariencia")) {
                    Picker("Modo", selection: $selectedTheme) {
                        Text("Sistema").tag(0)
                        Text("Claro").tag(1)
                        Text("Oscuro").tag(2)
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Edad")) {
                    Picker("Rango", selection: $selectedAgeGroup) {
                        Text("4 a 7 años").tag(0)
                        Text("8 a 12 años").tag(1)
                        Text("13 a 16 años").tag(2)
                        Text("16 a 21 años").tag(3)
                    }
                    .pickerStyle(.segmented)

                    let t = StressEntry.thresholds(for: selectedAgeGroup)
                    Text("Ritmo esperado: \(t.min) – \(t.max) bpm")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Text("CORDIS es una app educativa. No sustituye la orientación de un profesional.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Configuración")
        }
        .onAppear {
            ensureSettingsExists()
            load()
        }
        .onChange(of: selectedTheme) { _ in save() }
        .onChange(of: selectedAgeGroup) { _ in save() }
        .onChange(of: preferredName) { _ in save() }
        .onChange(of: objective) { _ in save() }
        .onChange(of: reminderEnabled) { _ in save() }
        .onChange(of: reminderTime) { _ in save() }
        .onChange(of: saveChatHistory) { _ in save() }
    }

    // MARK: - Load/Save

    private func ensureSettingsExists() {
        if settingsArr.isEmpty {
            context.insert(AppSettings())
            try? context.save()
        }
    }

    private func load() {
        guard let s = settingsArr.first else { return }

        selectedTheme = s.themeMode
        selectedAgeGroup = s.ageGroup
        preferredName = s.preferredName

        objective = s.objective
        reminderEnabled = s.reminderEnabled
        saveChatHistory = s.saveChatHistory

        // armar Date desde hour/minute
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = s.reminderHour
        comps.minute = s.reminderMinute
        reminderTime = Calendar.current.date(from: comps) ?? Date()
    }

    private func save() {
        ensureSettingsExists()
        guard let s = settingsArr.first else { return }

        s.themeMode = selectedTheme
        s.ageGroup = selectedAgeGroup
        s.preferredName = preferredName.trimmingCharacters(in: .whitespacesAndNewlines)

        s.objective = objective
        s.reminderEnabled = reminderEnabled

        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        s.reminderHour = comps.hour ?? 20
        s.reminderMinute = comps.minute ?? 0

        // Si apaga historial: borramos mensajes guardados
        if s.saveChatHistory == true && saveChatHistory == false {
            for m in chatMessages { context.delete(m) }
            try? context.save()
        }
        s.saveChatHistory = saveChatHistory

        try? context.save()

        // Notificaciones
        if reminderEnabled {
            requestAndScheduleReminder(hour: s.reminderHour, minute: s.reminderMinute)
        } else {
            cancelReminder()
        }
    }

    // MARK: - Notifications
    private func requestAndScheduleReminder(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            scheduleReminder(hour: hour, minute: minute)
        }
    }

    private func scheduleReminder(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["cordis.dailyReminder"])

        var date = DateComponents()
        date.hour = hour
        date.minute = minute

        let content = UNMutableNotificationContent()
        content.title = "CORDIS"
        content.body = "Hora de registrar tu BPM para mantener tu racha 💪"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "cordis.dailyReminder", content: content, trigger: trigger)

        center.add(request)
    }

    private func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["cordis.dailyReminder"])
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [AppSettings.self, ChatMessage.self], inMemory: true)
}
