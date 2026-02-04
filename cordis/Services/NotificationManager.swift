//
//  NotificationManager.swift
//  cordis
//
//  Created for CORDIS App
//

import Foundation
import Combine
import UserNotifications

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized: Bool = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let notificationCenter = UNUserNotificationCenter.current()
    private let dailyReminderIdentifier = "cordis.daily.reminder"

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            isAuthorized = false
            return false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isAuthorized = settings.authorizationStatus == .authorized
    }

    // MARK: - Daily Reminder

    func scheduleDailyReminder(hour: Int, minute: Int, title: String? = nil, body: String? = nil) async {
        // Remove existing reminder first
        await cancelDailyReminder()

        if !isAuthorized {
            let granted = await requestAuthorization()
            if !granted { return }
        }

        let content = UNMutableNotificationContent()
        content.title = title ?? String(localized: "reminder_title")
        content.body = body ?? String(localized: "reminder_body")
        content.sound = .default
        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
            print("Daily reminder scheduled for \(hour):\(String(format: "%02d", minute))")
        } catch {
            print("Failed to schedule daily reminder: \(error)")
        }
    }

    func cancelDailyReminder() async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
    }

    func isDailyReminderScheduled() async -> Bool {
        let requests = await notificationCenter.pendingNotificationRequests()
        return requests.contains { $0.identifier == dailyReminderIdentifier }
    }

    // MARK: - Stress Alert

    func sendHighStressAlert(bpm: Int) async {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "high_stress_alert_title")
        content.body = String(localized: "high_stress_alert_body \(bpm)")
        content.sound = .default
        content.interruptionLevel = .timeSensitive

        let request = UNNotificationRequest(
            identifier: "cordis.stress.alert.\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            print("Failed to send stress alert: \(error)")
        }
    }

    // MARK: - Badge Management

    func clearBadge() async {
        do {
            try await notificationCenter.setBadgeCount(0)
        } catch {
            print("Failed to clear badge: \(error)")
        }
    }

    // MARK: - Clear All Notifications

    func clearAllNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
    }
}
