//
//  HomeView.swift
//  cordis
//
//  ubaldo orozco on 23/12/25
//  Redesigned with glassmorphism
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var selectedTab: Int
    @Environment(\.modelContext) private var context
    @Query(sort: \StressEntry.timestamp, order: .reverse) private var entries: [StressEntry]
    @Query private var statsArr: [UserStats]
    @Query private var settingsArr: [AppSettings]

    @StateObject private var healthKit = HealthKitManager.shared

    @State private var bpmInput = ""
    @State private var explosion = false
    @State private var confetti = false
    @State private var showingMeditation = false
    @State private var showingManualMeasurement = false
    @State private var showInputError = false
    @State private var inputShakeOffset: CGFloat = 0
    @State private var showHealthKitSaveConfirmation = false

    @FocusState private var bpmFocused: Bool

    private var settings: AppSettings? { settingsArr.first }
    private var ageGroup: Int { settings?.ageGroup ?? 2 }
    private var healthKitEnabled: Bool { settings?.healthKitEnabled ?? false }

    private var ultimo: StressEntry? { entries.first }
    private var ultimoBPM: Int { ultimo?.bpm ?? 0 }
    private var necesitaMeditar: Bool {
        let t = StressEntry.thresholds(for: ultimo?.ageGroup ?? ageGroup)
        return ultimoBPM > t.max
    }

    private var backgroundColorScheme: AnimatedGlassBackground.BackgroundColorScheme {
        if explosion { return .stress }
        if let ultimo = ultimo {
            let t = StressEntry.thresholds(for: ultimo.ageGroup)
            if ultimo.bpm < t.min + 10 { return .success }
            if ultimo.bpm > t.max { return .stress }
        }
        return .calm
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGlassBackground(colorScheme: backgroundColorScheme)
                    .animation(.easeInOut(duration: 1.2), value: explosion)

                if confetti { ConfettiView() }

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection

                        // HealthKit or Manual Input
                        inputSection

                        // Last Entry Info
                        lastEntrySection

                        // Current Level
                        if let ultimo = entries.first {
                            currentLevelSection(entry: ultimo)
                        }

                        // Emergency Meditation
                        if necesitaMeditar {
                            emergencyMeditationButton
                        }

                        // Quick Actions
                        quickActionsSection

                        Spacer(minLength: 90)
                    }
                    .padding(.vertical, 24)
                    .frame(maxWidth: 700)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                ensureStatsExists()
                if healthKitEnabled && healthKit.isAvailable {
                    Task {
                        if !healthKit.isAuthorized {
                            _ = await healthKit.requestAuthorization()
                        }
                        await healthKit.fetchLatestHeartRate()
                    }
                }
            }
            .sheet(isPresented: $showingMeditation) {
                MeditationView()
            }
            .fullScreenCover(isPresented: $showingManualMeasurement) {
                ManualMeasurementView { bpm in
                    saveEntry(bpm: bpm)
                }
            }
            .onChange(of: healthKit.latestHeartRate) { oldValue, newValue in
                // Auto-save HealthKit reading when it changes (but not on initial load)
                if let newBpm = newValue, oldValue != nil, let oldBpm = oldValue, newBpm != oldBpm {
                    saveHealthKitEntry(bpm: Int(newBpm))
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("CORDIS")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundColor(.primary)
                .shadow(color: .black.opacity(0.15), radius: 10)

            Text(String(localized: "home_title"))
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(spacing: 16) {
            // HealthKit Status Card
            if healthKitEnabled && healthKit.isAvailable {
                healthKitCard
            }

            // Manual Input
            GlassCard {
                VStack(spacing: 16) {
                    Text(String(localized: "home_enter_bpm"))
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    TextField(
                        "",
                        text: $bpmInput,
                        prompt: Text("72").foregroundStyle(.primary.opacity(0.3))
                    )
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    #endif
                    .multilineTextAlignment(.center)
                    .focused($bpmFocused)
                    .offset(x: inputShakeOffset)
                    .onChange(of: bpmInput) { _, newValue in
                        bpmInput = newValue.filter(\.isNumber)
                        if showInputError { showInputError = false }
                    }
                    #if os(iOS)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button(String(localized: "common_done")) { bpmFocused = false }
                        }
                    }
                    #endif

                    if showInputError {
                        Text(String(localized: "validation_bpm_range"))
                            .font(.caption)
                            .foregroundStyle(.red)
                            .transition(.opacity)
                    }

                    HStack(spacing: 12) {
                        GlassButton(String(localized: "home_save"), icon: "heart.fill", style: .primary) {
                            analizar()
                        }

                        GlassButton(String(localized: "home_measure_manual"), icon: "hand.raised", style: .secondary) {
                            showingManualMeasurement = true
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - HealthKit Card

    private var healthKitCard: some View {
        GlassCardAccent(accentColor: .green) {
            HStack(spacing: 16) {
                Image(systemName: "applewatch")
                    .font(.title)
                    .foregroundStyle(.green)

                VStack(alignment: .leading, spacing: 4) {
                    if let hr = healthKit.latestHeartRate {
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(Int(hr))")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                            Text("BPM")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if let time = healthKit.formattedLastReadingTime() {
                            Text("\(String(localized: "healthkit_last_reading")): \(time)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text(String(localized: "healthkit_no_data"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if healthKit.latestHeartRate != nil {
                    Button {
                        if let hr = healthKit.latestHeartRate {
                            saveHealthKitEntry(bpm: Int(hr))
                            withAnimation { showHealthKitSaveConfirmation = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { showHealthKitSaveConfirmation = false }
                            }
                        }
                    } label: {
                        Image(systemName: showHealthKitSaveConfirmation ? "checkmark.circle.fill" : "heart.circle.fill")
                            .font(.title2)
                            .foregroundStyle(showHealthKitSaveConfirmation ? .white : .green)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .accessibilityLabel(String(localized: "healthkit_save"))
                }

                Button {
                    Task {
                        await healthKit.fetchLatestHeartRate()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Last Entry Section

    private var lastEntrySection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                if let ultimo {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(.purple)
                        Text("\(String(localized: "home_last_entry")): \(relativeString(since: ultimo.timestamp))")
                            .font(.subheadline.bold())
                    }

                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.yellow)
                            .padding(.top, 2)
                        Text(consejoPara(bpm: ultimo.bpm, ageGroup: ultimo.ageGroup))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue)
                        Text(String(localized: "home_no_entries"))
                            .font(.subheadline)
                    }
                }

                Divider()

                let days = statsArr.first?.streakDays ?? 0
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text(streakText(days: days))
                        .font(.subheadline.bold())
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Current Level Section

    private func currentLevelSection(entry: StressEntry) -> some View {
        let accentColor = entry.color

        return GlassCardAccent(accentColor: accentColor) {
            VStack(spacing: 12) {
                Text(String(localized: "home_last_entry"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(localizedStressLevel(entry.stressLevel))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(accentColor)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(entry.bpm)")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                    Text("BPM")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }

    // MARK: - Emergency Meditation Button

    private var emergencyMeditationButton: some View {
        GlassCardDanger {
            VStack(spacing: 12) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40))
                    .foregroundStyle(.red)

                Text(String(localized: "home_breathe"))
                    .font(.headline)

                GlassButton(String(localized: "home_meditate"), icon: "sparkles", style: .danger) {
                    showingMeditation = true
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                GlassPillButton(String(localized: "stats_entries"), icon: "list.bullet") {
                    selectedTab = 1
                }
                Text("\(entries.count)")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
        }
    }

    // MARK: - Helper Methods

    private func ensureStatsExists() {
        if statsArr.isEmpty {
            context.insert(UserStats())
            do { try context.save() } catch { print("SAVE ERROR (stats bootstrap):", error) }
        }
    }

    private func analizar() {
        let trimmed = bpmInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let bpm = Int(trimmed), (30...220).contains(bpm) else {
            withAnimation(.spring(duration: 0.3)) { showInputError = true }
            // Shake animation
            withAnimation(.default) { inputShakeOffset = 10 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.default) { inputShakeOffset = -8 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.default) { inputShakeOffset = 5 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.default) { inputShakeOffset = 0 }
            }
            return
        }
        showInputError = false
        saveEntry(bpm: bpm)
        bpmInput = ""
        bpmFocused = false
    }

    private func saveEntry(bpm: Int) {
        ensureStatsExists()

        let nuevo = StressEntry(bpm: bpm, ageGroup: ageGroup)
        context.insert(nuevo)
        updateStreak(for: Date())

        do { try context.save() } catch { print("SAVE ERROR (entry):", error) }

        let t = StressEntry.thresholds(for: ageGroup)

        if bpm >= t.min && bpm <= (t.min + 10) {
            confetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { confetti = false }
        }
        if bpm > t.max {
            explosion = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { explosion = false }
        }
    }

    private func saveHealthKitEntry(bpm: Int) {
        // Only save if we don't already have an entry with this exact BPM in the last minute
        let oneMinuteAgo = Date().addingTimeInterval(-60)
        let recentEntries = entries.filter { $0.timestamp > oneMinuteAgo && $0.bpm == bpm }
        guard recentEntries.isEmpty else { return }

        saveEntry(bpm: bpm)
    }

    private func updateStreak(for now: Date) {
        guard let stats = statsArr.first else { return }
        let cal = Calendar.current
        let today = cal.startOfDay(for: now)

        guard let last = stats.lastStreakDay else {
            stats.streakDays = 1
            stats.lastStreakDay = today
            return
        }

        if cal.isDate(last, inSameDayAs: today) { return }

        if let yesterday = cal.date(byAdding: .day, value: -1, to: today),
           cal.isDate(last, inSameDayAs: yesterday) {
            stats.streakDays += 1
            stats.lastStreakDay = today
            return
        }

        stats.streakDays = 1
        stats.lastStreakDay = today
    }

    private func relativeString(since date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.locale = .current
        f.unitsStyle = .full
        return f.localizedString(for: date, relativeTo: Date())
    }

    private func consejoPara(bpm: Int, ageGroup: Int) -> String {
        let t = StressEntry.thresholds(for: ageGroup)
        if bpm < t.min { return String(localized: "advice_low_bpm") }
        if bpm > t.max { return String(localized: "advice_high_bpm") }
        if bpm < (t.min + 10) { return String(localized: "advice_excellent") }
        if bpm < (t.max - 15) { return String(localized: "advice_normal") }
        return String(localized: "advice_elevated")
    }

    private func streakText(days: Int) -> String {
        if days <= 0 { return String(localized: "home_streak") + ": 0" }
        return "\(String(localized: "home_streak")): \(days)"
    }

    private func localizedStressLevel(_ raw: String) -> String {
        switch raw.lowercased() {
        case "excelente": return String(localized: "stress_excellent")
        case "normal": return String(localized: "stress_normal")
        case "elevado": return String(localized: "stress_elevated")
        case "arritmia": return String(localized: "stress_arrhythmia")
        case "paro cardiaco": return String(localized: "stress_low")
        default: return raw
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
        .modelContainer(for: [StressEntry.self, UserStats.self, AppSettings.self], inMemory: true)
}
