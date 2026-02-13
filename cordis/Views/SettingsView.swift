//
//  SettingsView.swift
//  cordis
//
//  created by ubaldo orozoco camargo on 23/12/25
//  Redesigned with glassmorphism
//

import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var settingsArr: [AppSettings]
    @Query(sort: \ChatMessage.timestamp, order: .reverse) private var chatMessages: [ChatMessage]

    @StateObject private var healthKit = HealthKitManager.shared
    @StateObject private var notifications = NotificationManager.shared

    @State private var selectedTheme: Int = 0
    @State private var selectedAgeGroup: Int = 0
    @State private var preferredName: String = ""
    @State private var objective: Int = 0
    @State private var reminderEnabled: Bool = false
    @State private var reminderTime: Date = Date()
    @State private var saveChatHistory: Bool = true
    @State private var healthKitEnabled: Bool = false
    @State private var showMedicalInfo = false
    @State private var showPrivacyPolicy = false
    @State private var showAbout = false
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGlassBackground(colorScheme: .calm)

                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Section
                        profileSection

                        // Objective Section
                        objectiveSection

                        // HealthKit Section
                        healthKitSection

                        // Reminder Section
                        reminderSection

                        // Privacy Section
                        privacySection

                        // Appearance Section
                        appearanceSection

                        // Age Group Section
                        ageGroupSection

                        // Medical Info Link
                        medicalInfoButton

                        // Privacy Policy Link
                        privacyPolicyButton

                        // About Link
                        aboutButton

                        // Disclaimer
                        disclaimerSection
                    }
                    .padding()
                    .frame(maxWidth: 700)
                }
            }
            .navigationTitle(String(localized: "settings_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
        .onAppear {
            ensureSettingsExists()
            load()
        }
        .onChange(of: selectedTheme) { _, _ in save() }
        .onChange(of: selectedAgeGroup) { _, _ in save() }
        .onChange(of: preferredName) { _, _ in save() }
        .onChange(of: objective) { _, _ in save() }
        .onChange(of: reminderEnabled) { _, _ in save() }
        .onChange(of: reminderTime) { _, _ in save() }
        .onChange(of: saveChatHistory) { _, _ in save() }
        .onChange(of: healthKitEnabled) { _, _ in save() }
        .sheet(isPresented: $showMedicalInfo) {
            MedicalInfoView()
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
    }

    // MARK: - Profile Section

    private var profileSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Label(String(localized: "settings_profile"), systemImage: "person.circle")
                    .font(.headline)
                    .foregroundStyle(.purple)

                TextField(String(localized: "settings_name"), text: $preferredName)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    #if os(iOS)
                    .textInputAutocapitalization(.words)
                    #endif
                    .autocorrectionDisabled()

                Text("The assistant will call you by this name.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Objective Section

    private var objectiveSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Label(String(localized: "settings_objective"), systemImage: "target")
                    .font(.headline)
                    .foregroundStyle(.purple)

                VStack(spacing: 8) {
                    objectiveButton(String(localized: "objective_reduce_stress"), icon: "heart.fill", tag: 0)
                    objectiveButton(String(localized: "objective_track_fitness"), icon: "figure.run", tag: 1)
                    objectiveButton(String(localized: "objective_improve_sleep"), icon: "moon.fill", tag: 2)
                    objectiveButton(String(localized: "objective_general_wellness"), icon: "sparkles", tag: 3)
                }
            }
        }
    }

    private func objectiveButton(_ title: String, icon: String, tag: Int) -> some View {
        Button {
            objective = tag
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(objective == tag ? .white : .purple)
                Text(title)
                    .foregroundStyle(objective == tag ? .white : .primary)
                Spacer()
                if objective == tag {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                }
            }
            .padding()
            .background(objective == tag ? Color.purple : Color.clear)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - HealthKit Section

    private var healthKitSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Label(String(localized: "settings_healthkit"), systemImage: "heart.text.square")
                    .font(.headline)
                    .foregroundStyle(.green)

                Toggle(String(localized: "settings_healthkit_enable"), isOn: $healthKitEnabled)
                    .tint(.green)
                    .onChange(of: healthKitEnabled) { _, newValue in
                        if newValue {
                            Task {
                                let authorized = await healthKit.requestAuthorization()
                                if !authorized {
                                    healthKitEnabled = false
                                }
                            }
                        }
                    }

                Text(String(localized: "settings_healthkit_description"))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if healthKitEnabled && healthKit.isAuthorized {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Connected to Apple Health")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
        }
    }

    // MARK: - Reminder Section

    private var reminderSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Label(String(localized: "settings_notifications"), systemImage: "bell.fill")
                    .font(.headline)
                    .foregroundStyle(.orange)

                Toggle(String(localized: "settings_reminder"), isOn: $reminderEnabled)
                    .tint(.orange)

                if reminderEnabled {
                    DatePicker(String(localized: "settings_reminder_time"), selection: $reminderTime, displayedComponents: .hourAndMinute)
                }

                Text("Daily reminder to record your BPM")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Privacy Section

    private var privacySection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Label(String(localized: "settings_privacy"), systemImage: "lock.shield")
                    .font(.headline)
                    .foregroundStyle(.blue)

                Toggle(String(localized: "settings_save_chat"), isOn: $saveChatHistory)
                    .tint(.blue)

                Text("If disabled, chat messages will not be saved")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Label(String(localized: "settings_appearance"), systemImage: "paintbrush")
                    .font(.headline)
                    .foregroundStyle(.pink)

                Picker(String(localized: "settings_theme"), selection: $selectedTheme) {
                    Text(String(localized: "settings_theme_system")).tag(0)
                    Text(String(localized: "settings_theme_light")).tag(1)
                    Text(String(localized: "settings_theme_dark")).tag(2)
                }
                .pickerStyle(.segmented)
            }
        }
    }

    // MARK: - Age Group Section

    private var ageGroupSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Label(String(localized: "settings_age_group"), systemImage: "person.2")
                    .font(.headline)
                    .foregroundStyle(.teal)

                Picker("", selection: $selectedAgeGroup) {
                    Text(String(localized: "age_13_17")).tag(0)
                    Text(String(localized: "age_18_35")).tag(1)
                    Text(String(localized: "age_36_59")).tag(2)
                    Text(String(localized: "age_60_99")).tag(3)
                }
                .pickerStyle(.segmented)

                let t = StressEntry.thresholds(for: selectedAgeGroup)
                Text("Expected range: \(t.min) – \(t.max) BPM")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Medical Info Button

    private var medicalInfoButton: some View {
        GlassButton(String(localized: "settings_medical_info"), icon: "cross.case", style: .secondary) {
            showMedicalInfo = true
        }
    }

    // MARK: - Privacy Policy Button

    private var privacyPolicyButton: some View {
        GlassButton(String(localized: "settings_privacy_policy"), icon: "hand.raised.fill", style: .secondary) {
            showPrivacyPolicy = true
        }
    }

    // MARK: - About Button

    private var aboutButton: some View {
        GlassButton(String(localized: "settings_about"), icon: "info.circle", style: .secondary) {
            showAbout = true
        }
    }

    // MARK: - Disclaimer Section

    private var disclaimerSection: some View {
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
        healthKitEnabled = s.healthKitEnabled

        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = s.reminderHour
        comps.minute = s.reminderMinute
        reminderTime = Calendar.current.date(from: comps) ?? Date()

        // Mark loading complete after a short delay to let onChange settle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
        }
    }

    private func save() {
        // Skip saving during initial load to prevent multiple reminder schedules
        guard !isLoading else { return }

        ensureSettingsExists()
        guard let s = settingsArr.first else { return }

        s.themeMode = selectedTheme
        s.ageGroup = selectedAgeGroup
        s.preferredName = preferredName.trimmingCharacters(in: .whitespacesAndNewlines)

        s.objective = objective
        s.reminderEnabled = reminderEnabled
        s.healthKitEnabled = healthKitEnabled

        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        s.reminderHour = comps.hour ?? 20
        s.reminderMinute = comps.minute ?? 0

        if s.saveChatHistory == true && saveChatHistory == false {
            for m in chatMessages { context.delete(m) }
            try? context.save()
        }
        s.saveChatHistory = saveChatHistory

        try? context.save()

        // Handle notifications
        if reminderEnabled {
            Task {
                await notifications.scheduleDailyReminder(hour: s.reminderHour, minute: s.reminderMinute)
            }
        } else {
            Task {
                await notifications.cancelDailyReminder()
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [AppSettings.self, ChatMessage.self], inMemory: true)
}
