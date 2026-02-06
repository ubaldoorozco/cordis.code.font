//
//  NotificationSetupView.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI

struct NotificationSetupView: View {
    @Binding var reminderEnabled: Bool
    @Binding var reminderHour: Int
    @Binding var reminderMinute: Int
    var onContinue: () -> Void
    var onSkip: () -> Void

    @StateObject private var notifications = NotificationManager.shared
    @State private var isRequesting = false
    @State private var reminderTime = Calendar.current.date(
        from: DateComponents(hour: 9, minute: 0)
    ) ?? Date()

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 120, height: 120)

                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 12) {
                Text(String(localized: "onboarding_notifications_title"))
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(String(localized: "onboarding_notifications_description"))
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Time picker
            GlassCard {
                VStack(spacing: 16) {
                    Text(String(localized: "onboarding_notifications_time"))
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))

                    DatePicker(
                        "",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 12) {
                GlassButton(
                    String(localized: "onboarding_notifications_enable"),
                    icon: "bell.fill",
                    style: .primary,
                    isLoading: isRequesting
                ) {
                    enableNotifications()
                }

                Button {
                    onSkip()
                } label: {
                    Text(String(localized: "onboarding_notifications_skip"))
                        .font(.body.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.vertical, 12)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    private func enableNotifications() {
        isRequesting = true
        Task {
            let authorized = await notifications.requestAuthorization()
            if authorized {
                let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                let hour = components.hour ?? 9
                let minute = components.minute ?? 0
                await notifications.scheduleDailyReminder(hour: hour, minute: minute)
                reminderEnabled = true
                reminderHour = hour
                reminderMinute = minute
            }
            isRequesting = false
            onContinue()
        }
    }
}

#Preview {
    ZStack {
        AnimatedGlassBackground(colorScheme: .calm)
        NotificationSetupView(
            reminderEnabled: .constant(false),
            reminderHour: .constant(9),
            reminderMinute: .constant(0),
            onContinue: {},
            onSkip: {}
        )
    }
}
