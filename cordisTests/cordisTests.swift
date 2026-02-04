//
//  cordisTests.swift
//  cordisTests
//
//  Created by Balo Orozco on 23/12/25.
//  Unit tests for CORDIS app models
//

import Testing
import SwiftUI
@testable import cordis

// MARK: - StressEntry Tests

struct StressEntryTests {

    // MARK: - Thresholds Tests

    @Test func thresholdsForAgeGroup0() {
        let thresholds = StressEntry.thresholds(for: 0)
        #expect(thresholds.min == 70)
        #expect(thresholds.max == 120)
    }

    @Test func thresholdsForAgeGroup1() {
        let thresholds = StressEntry.thresholds(for: 1)
        #expect(thresholds.min == 65)
        #expect(thresholds.max == 115)
    }

    @Test func thresholdsForAgeGroup2() {
        let thresholds = StressEntry.thresholds(for: 2)
        #expect(thresholds.min == 60)
        #expect(thresholds.max == 110)
    }

    @Test func thresholdsForAgeGroup3() {
        let thresholds = StressEntry.thresholds(for: 3)
        #expect(thresholds.min == 55)
        #expect(thresholds.max == 100)
    }

    @Test func thresholdsForDefaultAgeGroup() {
        let thresholds = StressEntry.thresholds(for: 99)
        #expect(thresholds.min == 60)
        #expect(thresholds.max == 100)
    }

    // MARK: - Stress Level Tests

    @Test func levelBelowMinimumShowsCardiacArrest() {
        // Age group 2: min is 60
        let level = StressEntry.level(from: 50, ageGroup: 2)
        #expect(level == "paro cardiaco")
    }

    @Test func levelAboveMaximumShowsArrhythmia() {
        // Age group 2: max is 110
        let level = StressEntry.level(from: 120, ageGroup: 2)
        #expect(level == "arritmia")
    }

    @Test func levelExcellentInLowRange() {
        // Age group 2: min is 60, so 60-69 should be "Excelente"
        let level = StressEntry.level(from: 65, ageGroup: 2)
        #expect(level == "Excelente")
    }

    @Test func levelNormalInMidRange() {
        // Age group 2: 70-94 should be "Normal"
        let level = StressEntry.level(from: 80, ageGroup: 2)
        #expect(level == "Normal")
    }

    @Test func levelElevatedInHighRange() {
        // Age group 2: 95-110 should be "Elevado"
        let level = StressEntry.level(from: 100, ageGroup: 2)
        #expect(level == "Elevado")
    }

    // MARK: - Color Tests

    @Test func colorPurpleForBelowMinimum() {
        let entry = StressEntry(bpm: 50, ageGroup: 2)
        #expect(entry.color == .purple)
    }

    @Test func colorRedForAboveMaximum() {
        let entry = StressEntry(bpm: 120, ageGroup: 2)
        #expect(entry.color == .red)
    }

    @Test func colorGreenForExcellent() {
        let entry = StressEntry(bpm: 65, ageGroup: 2)
        #expect(entry.color == .green)
    }

    @Test func colorBlueForNormal() {
        let entry = StressEntry(bpm: 80, ageGroup: 2)
        #expect(entry.color == .blue)
    }

    @Test func colorOrangeForElevated() {
        let entry = StressEntry(bpm: 100, ageGroup: 2)
        #expect(entry.color == .orange)
    }

    // MARK: - Initialization Tests

    @Test func initializationSetsCorrectValues() {
        let entry = StressEntry(bpm: 75, ageGroup: 1)
        #expect(entry.bpm == 75)
        #expect(entry.ageGroup == 1)
        #expect(entry.stressLevel == "Normal")
    }

    @Test func initializationWithDefaultAgeGroup() {
        let entry = StressEntry(bpm: 70)
        #expect(entry.ageGroup == 2) // Default is 2
    }
}

// MARK: - UserStats Tests

struct UserStatsTests {

    @Test func initializationWithDefaults() {
        let stats = UserStats()
        #expect(stats.streakDays == 0)
        #expect(stats.lastStreakDay == nil)
    }

    @Test func initializationWithCustomValues() {
        let date = Date()
        let stats = UserStats(streakDays: 5, lastStreakDay: date)
        #expect(stats.streakDays == 5)
        #expect(stats.lastStreakDay == date)
    }
}

// MARK: - AppSettings Tests

struct AppSettingsTests {

    @Test func initializationWithDefaults() {
        let settings = AppSettings()
        #expect(settings.themeMode == 0)
        #expect(settings.languageMode == 0)
        #expect(settings.ageGroup == 2)
        #expect(settings.preferredName == "")
        #expect(settings.objective == 0)
        #expect(settings.reminderEnabled == false)
        #expect(settings.reminderHour == 9)
        #expect(settings.reminderMinute == 0)
        #expect(settings.saveChatHistory == true)
        #expect(settings.healthKitEnabled == false)
    }

    @Test func initializationWithCustomTheme() {
        let settings = AppSettings(themeMode: 2)
        #expect(settings.themeMode == 2) // Dark mode
    }

    @Test func initializationWithCustomReminder() {
        let settings = AppSettings(
            reminderEnabled: true,
            reminderHour: 20,
            reminderMinute: 30
        )
        #expect(settings.reminderEnabled == true)
        #expect(settings.reminderHour == 20)
        #expect(settings.reminderMinute == 30)
    }

    @Test func initializationWithHealthKitEnabled() {
        let settings = AppSettings(healthKitEnabled: true)
        #expect(settings.healthKitEnabled == true)
    }

    @Test func initializationWithAllAgeGroups() {
        for ageGroup in 0...3 {
            let settings = AppSettings(ageGroup: ageGroup)
            #expect(settings.ageGroup == ageGroup)
        }
    }
}

// MARK: - ChatMessage Tests

struct ChatMessageTests {

    @Test func initializationWithUserRole() {
        let message = ChatMessage(role: "user", text: "Hello")
        #expect(message.role == "user")
        #expect(message.text == "Hello")
    }

    @Test func initializationWithAssistantRole() {
        let message = ChatMessage(role: "assistant", text: "How can I help?")
        #expect(message.role == "assistant")
        #expect(message.text == "How can I help?")
    }

    @Test func initializationSetsTimestamp() {
        let beforeCreation = Date()
        let message = ChatMessage(role: "user", text: "Test")
        let afterCreation = Date()

        #expect(message.timestamp >= beforeCreation)
        #expect(message.timestamp <= afterCreation)
    }

    @Test func initializationWithCustomTimestamp() {
        let customDate = Date(timeIntervalSince1970: 0)
        let message = ChatMessage(role: "user", text: "Test", timestamp: customDate)
        #expect(message.timestamp == customDate)
    }
}

// MARK: - Age Group Label Tests

struct AgeGroupTests {

    @Test func ageGroup0Represents4To7Years() {
        let thresholds = StressEntry.thresholds(for: 0)
        // 4-7 years have higher heart rates
        #expect(thresholds.min == 70)
        #expect(thresholds.max == 120)
    }

    @Test func ageGroup1Represents8To12Years() {
        let thresholds = StressEntry.thresholds(for: 1)
        #expect(thresholds.min == 65)
        #expect(thresholds.max == 115)
    }

    @Test func ageGroup2Represents13To16Years() {
        let thresholds = StressEntry.thresholds(for: 2)
        #expect(thresholds.min == 60)
        #expect(thresholds.max == 110)
    }

    @Test func ageGroup3Represents17To21Years() {
        let thresholds = StressEntry.thresholds(for: 3)
        #expect(thresholds.min == 55)
        #expect(thresholds.max == 100)
    }

    @Test func olderAgeGroupsHaveLowerThresholds() {
        // Verify that as age increases, heart rate thresholds decrease
        let group0 = StressEntry.thresholds(for: 0)
        let group1 = StressEntry.thresholds(for: 1)
        let group2 = StressEntry.thresholds(for: 2)
        let group3 = StressEntry.thresholds(for: 3)

        #expect(group0.min > group1.min)
        #expect(group1.min > group2.min)
        #expect(group2.min > group3.min)

        #expect(group0.max > group1.max)
        #expect(group1.max > group2.max)
        #expect(group2.max > group3.max)
    }
}

// MARK: - Boundary Tests

struct BoundaryTests {

    @Test func exactMinimumThresholdIsExcellent() {
        // At exactly the minimum, should be "Excelente"
        let level = StressEntry.level(from: 60, ageGroup: 2)
        #expect(level == "Excelente")
    }

    @Test func exactMaximumThresholdIsElevated() {
        // At exactly the maximum, should be "Elevado"
        let level = StressEntry.level(from: 110, ageGroup: 2)
        #expect(level == "Elevado")
    }

    @Test func oneBelowMinimumIsCardiacArrest() {
        // One below minimum should be "paro cardiaco"
        let level = StressEntry.level(from: 59, ageGroup: 2)
        #expect(level == "paro cardiaco")
    }

    @Test func oneAboveMaximumIsArrhythmia() {
        // One above maximum should be "arritmia"
        let level = StressEntry.level(from: 111, ageGroup: 2)
        #expect(level == "arritmia")
    }
}
