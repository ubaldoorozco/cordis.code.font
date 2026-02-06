//
//  Models.swift
//  cordis
//
//  ubaldo orozco on 23/12/25
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - StressEntry

@Model
final class StressEntry {
    @Attribute(.unique) var id: UUID = UUID()
    var bpm: Int
    var timestamp: Date
    var stressLevel: String
    /// 0 = 4–7, 1 = 8–12, 2 = 13–16, 3 = 17–21
    var ageGroup: Int

    init(bpm: Int, timestamp: Date = .now, ageGroup: Int = 2) {
        self.bpm = bpm
        self.timestamp = timestamp
        self.ageGroup = ageGroup
        self.stressLevel = StressEntry.level(from: bpm, ageGroup: ageGroup)
    }

    static func thresholds(for ageGroup: Int) -> (min: Int, max: Int) {
        // Rangos aproximados de reposo según AHA (American Heart Association)
        // para diferentes grupos de edad.
        switch ageGroup {
        case 0: return (70, 120) // 4–7 años
        case 1: return (65, 115) // 8–12 años
        case 2: return (60, 110) // 13–16 años
        case 3: return (55, 100) // 17–21 años
        default: return (60, 100) // Adulto general
        }
    }

    static func level(from bpm: Int, ageGroup: Int) -> String {
        let t = thresholds(for: ageGroup)

        if bpm < t.min { return "paro cardiaco" }
        if bpm > t.max { return "arritmia" } // (así se escribe)

        // Dentro de rango: conserva tu “estilo” de etiquetas
        switch bpm {
        case t.min..<(t.min + 10):  return "Excelente"
        case (t.min + 10)..<(t.max - 15): return "Normal"
        case (t.max - 15)...t.max:  return "Elevado"
        default: return "Normal"
        }
    }

    var color: Color {
        let t = StressEntry.thresholds(for: ageGroup)
        if bpm < t.min { return .purple }
        if bpm > t.max { return .red }
        // dentro de rango
        if bpm < (t.min + 10) { return .green }
        if bpm < (t.max - 15) { return .blue }
        return .orange
    }
}

@Model
final class UserStats {
    @Attribute(.unique) var id: UUID = UUID()
    var streakDays: Int
    var lastStreakDay: Date?

    init(streakDays: Int = 0, lastStreakDay: Date? = nil) {
        self.streakDays = streakDays
        self.lastStreakDay = lastStreakDay
    }
}

// MARK: - AppSettings

@Model
final class AppSettings {
    @Attribute(.unique) var id: UUID = UUID()
    /// 0 = sistema, 1 = claro, 2 = oscuro
    var themeMode: Int
    /// 0 = Español, 1 = Inglés
    var languageMode: Int
    /// 0 = 4–7, 1 = 8–12, 2 = 13–16, 3 = 17–21
    var ageGroup: Int
    /// User's preferred name for personalization
    var preferredName: String
    /// Health objective: 0 = reduce stress, 1 = track fitness, 2 = improve sleep, 3 = general wellness
    var objective: Int
    /// Whether daily reminders are enabled
    var reminderEnabled: Bool
    /// Hour for daily reminder (0-23)
    var reminderHour: Int
    /// Minute for daily reminder (0-59)
    var reminderMinute: Int
    /// Whether to save chat history
    var saveChatHistory: Bool
    /// Whether HealthKit integration is enabled
    var healthKitEnabled: Bool
    /// Whether onboarding has been completed
    var hasCompletedOnboarding: Bool
    /// Whether user has accepted the medical disclaimer
    var hasAcceptedDisclaimer: Bool
    /// Date when disclaimer was accepted
    var disclaimerAcceptedDate: Date?

    init(
        themeMode: Int = 0,
        languageMode: Int = 0,
        ageGroup: Int = 2,
        preferredName: String = "",
        objective: Int = 0,
        reminderEnabled: Bool = false,
        reminderHour: Int = 9,
        reminderMinute: Int = 0,
        saveChatHistory: Bool = true,
        healthKitEnabled: Bool = false,
        hasCompletedOnboarding: Bool = false,
        hasAcceptedDisclaimer: Bool = false,
        disclaimerAcceptedDate: Date? = nil
    ) {
        self.themeMode = themeMode
        self.languageMode = languageMode
        self.ageGroup = ageGroup
        self.preferredName = preferredName
        self.objective = objective
        self.reminderEnabled = reminderEnabled
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.saveChatHistory = saveChatHistory
        self.healthKitEnabled = healthKitEnabled
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.hasAcceptedDisclaimer = hasAcceptedDisclaimer
        self.disclaimerAcceptedDate = disclaimerAcceptedDate
    }
}

// MARK: - ChatMessage

@Model
final class ChatMessage {
    @Attribute(.unique) var id: UUID = UUID()
    /// "user" or "assistant"
    var role: String
    var text: String
    var timestamp: Date

    init(role: String, text: String, timestamp: Date = .now) {
        self.role = role
        self.text = text
        self.timestamp = timestamp
    }
}
