//
//  ScreenshotSeedData.swift
//  cordis
//
//  Screenshot-only: populates realistic sample data for App Store screenshots.
//

import Foundation
import SwiftData

enum ScreenshotSeedData {

    /// Injects sample data for screenshots. Skips if data already exists.
    static func seed(context: ModelContext, name: String) {
        // Guard: don't duplicate
        let settingsCount = (try? context.fetchCount(FetchDescriptor<AppSettings>())) ?? 0
        if settingsCount > 0 { return }

        // MARK: - AppSettings
        let settings = AppSettings(
            themeMode: 0,
            languageMode: 0,
            ageGroup: 1,
            preferredName: name,
            objective: 0,
            reminderEnabled: true,
            reminderHour: 9,
            reminderMinute: 0,
            saveChatHistory: true,
            healthKitEnabled: false,
            hasCompletedOnboarding: true,
            hasAcceptedDisclaimer: true,
            disclaimerAcceptedDate: Calendar.current.date(byAdding: .day, value: -14, to: .now)
        )
        context.insert(settings)

        // MARK: - UserStats
        let stats = UserStats(streakDays: 7, lastStreakDay: Calendar.current.startOfDay(for: .now))
        context.insert(stats)

        // MARK: - StressEntry (~25 entries over 14 days)
        // ageGroup 1 thresholds: 60-100
        // 60-69 Excelente (green), 70-84 Normal (blue), 85-100 Elevado (orange)
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)

        struct EntrySpec {
            let daysAgo: Int
            let hour: Int
            let bpm: Int
        }

        let specs: [EntrySpec] = [
            // Day -13 (2 entries)
            EntrySpec(daysAgo: 13, hour: 8,  bpm: 78),
            EntrySpec(daysAgo: 13, hour: 20, bpm: 72),
            // Day -12 (2 entries)
            EntrySpec(daysAgo: 12, hour: 9,  bpm: 82),
            EntrySpec(daysAgo: 12, hour: 15, bpm: 75),
            // Day -11 (1 entry)
            EntrySpec(daysAgo: 11, hour: 10, bpm: 88),
            // Day -10 (2 entries)
            EntrySpec(daysAgo: 10, hour: 7,  bpm: 68),
            EntrySpec(daysAgo: 10, hour: 19, bpm: 74),
            // Day -9 (2 entries)
            EntrySpec(daysAgo: 9, hour: 8,  bpm: 71),
            EntrySpec(daysAgo: 9, hour: 14, bpm: 90),
            // Day -8 (1 entry)
            EntrySpec(daysAgo: 8, hour: 11, bpm: 66),
            // Day -7 (2 entries) — streak starts
            EntrySpec(daysAgo: 7, hour: 9,  bpm: 73),
            EntrySpec(daysAgo: 7, hour: 21, bpm: 69),
            // Day -6 (2 entries)
            EntrySpec(daysAgo: 6, hour: 7,  bpm: 76),
            EntrySpec(daysAgo: 6, hour: 16, bpm: 85),
            // Day -5 (2 entries)
            EntrySpec(daysAgo: 5, hour: 8,  bpm: 62),
            EntrySpec(daysAgo: 5, hour: 18, bpm: 79),
            // Day -4 (2 entries)
            EntrySpec(daysAgo: 4, hour: 10, bpm: 91),
            EntrySpec(daysAgo: 4, hour: 20, bpm: 70),
            // Day -3 (2 entries)
            EntrySpec(daysAgo: 3, hour: 9,  bpm: 67),
            EntrySpec(daysAgo: 3, hour: 15, bpm: 77),
            // Day -2 (2 entries)
            EntrySpec(daysAgo: 2, hour: 8,  bpm: 63),
            EntrySpec(daysAgo: 2, hour: 19, bpm: 86),
            // Day -1 (2 entries)
            EntrySpec(daysAgo: 1, hour: 7,  bpm: 64),
            EntrySpec(daysAgo: 1, hour: 17, bpm: 72),
            // Today (1 entry — most recent, looks good on Home)
            EntrySpec(daysAgo: 0, hour: 9,  bpm: 65),
        ]

        for spec in specs {
            guard let date = cal.date(byAdding: .day, value: -spec.daysAgo, to: today),
                  let timestamp = cal.date(bySettingHour: spec.hour, minute: Int.random(in: 0...59), second: 0, of: date)
            else { continue }
            let entry = StressEntry(bpm: spec.bpm, timestamp: timestamp, ageGroup: 1)
            context.insert(entry)
        }

        // MARK: - ChatMessage (2 messages for Health Assistant)
        let userMsg = ChatMessage(
            role: "user",
            text: String(localized: "screenshot_chat_user"),
            timestamp: cal.date(byAdding: .hour, value: -1, to: .now) ?? .now
        )
        let assistantMsg = ChatMessage(
            role: "assistant",
            text: String(localized: "screenshot_chat_assistant \(name)"),
            timestamp: .now
        )
        context.insert(userMsg)
        context.insert(assistantMsg)

        do { try context.save() } catch { print("SEED ERROR:", error) }
    }
}
