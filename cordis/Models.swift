//
//  Models.swift
//  cordis
//
//  Extracted by assistant on 23/12/25
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class StressEntry {
    @Attribute(.unique) var id: UUID = UUID()
    var bpm: Int
    var timestamp: Date
    var stressLevel: String
    /// 0 = 4–7, 1 = 8–12, 2 = 13–16
    var ageGroup: Int

    init(bpm: Int, timestamp: Date = .now, ageGroup: Int = 2) {
        self.bpm = bpm
        self.timestamp = timestamp
        self.ageGroup = ageGroup
        self.stressLevel = StressEntry.level(from: bpm, ageGroup: ageGroup)
    }

    static func thresholds(for ageGroup: Int) -> (min: Int, max: Int) {
        // Rangos aproximados de reposo (simplificados) para 4–16 años.
        // Ajusta si quieres ser más estricto/relajado.
        switch ageGroup {
        case 0: return (70, 120) // 4–7
        case 1: return (65, 115) // 8–12
        default: return (60, 110) // 13–16
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

@Model
final class AppSettings {
    @Attribute(.unique) var id: UUID = UUID()
    /// 0 = sistema, 1 = claro, 2 = oscuro
    var themeMode: Int
    /// 0 = Español, 1 = Inglés (el usuario escribió “iglesia”, asumo “inglés”)
    var languageMode: Int
    /// 0 = 4–7, 1 = 8–12, 2 = 13–16
    var ageGroup: Int

    init(themeMode: Int = 0, languageMode: Int = 0, ageGroup: Int = 2) {
        self.themeMode = themeMode
        self.languageMode = languageMode
        self.ageGroup = ageGroup
    }
}
