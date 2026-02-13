//
//  OnboardingContainerView.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var context
    @Query private var settingsArr: [AppSettings]

    @State private var currentStep: OnboardingStep = .welcome
    @State private var userName: String = ""
    @State private var selectedAgeGroup: Int = 0
    @State private var selectedTheme: Int = 0
    @State private var hasAcceptedDisclaimer: Bool = false
    @State private var healthKitEnabled: Bool = false
    @State private var reminderEnabled: Bool = false
    @State private var reminderHour: Int = 9
    @State private var reminderMinute: Int = 0

    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case disclaimer = 1
        case profile = 2
        case healthKit = 3
        case notifications = 4
        case theme = 5
        case complete = 6

        var progress: Double {
            Double(rawValue) / Double(OnboardingStep.allCases.count - 1)
        }
    }

    var body: some View {
        ZStack {
            AnimatedGlassBackground(colorScheme: .calm)

            VStack(spacing: 0) {
                // Progress indicator
                if currentStep != .welcome && currentStep != .complete {
                    ProgressView(value: currentStep.progress)
                        .progressViewStyle(.linear)
                        .tint(.white)
                        .padding(.horizontal)
                        .padding(.top)
                }

                // Content
                TabView(selection: $currentStep) {
                    WelcomeView(onContinue: { nextStep() })
                        .tag(OnboardingStep.welcome)

                    DisclaimerView(
                        hasAccepted: $hasAcceptedDisclaimer,
                        onContinue: { nextStep() }
                    )
                    .tag(OnboardingStep.disclaimer)

                    ProfileSetupView(
                        userName: $userName,
                        selectedAgeGroup: $selectedAgeGroup,
                        onContinue: { nextStep() }
                    )
                    .tag(OnboardingStep.profile)

                    HealthKitSetupView(
                        healthKitEnabled: $healthKitEnabled,
                        onContinue: { nextStep() },
                        onSkip: { nextStep() }
                    )
                    .tag(OnboardingStep.healthKit)

                    NotificationSetupView(
                        reminderEnabled: $reminderEnabled,
                        reminderHour: $reminderHour,
                        reminderMinute: $reminderMinute,
                        onContinue: { nextStep() },
                        onSkip: { nextStep() }
                    )
                    .tag(OnboardingStep.notifications)

                    ThemeSetupView(
                        selectedTheme: $selectedTheme,
                        onContinue: { nextStep() }
                    )
                    .tag(OnboardingStep.theme)

                    OnboardingCompleteView(
                        userName: userName,
                        onFinish: { completeOnboarding() }
                    )
                    .tag(OnboardingStep.complete)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
            }
        }
    }

    private func nextStep() {
        withAnimation {
            if let nextIndex = OnboardingStep(rawValue: currentStep.rawValue + 1) {
                currentStep = nextIndex
            }
        }
    }

    private func completeOnboarding() {
        guard let settings = settingsArr.first else { return }

        settings.preferredName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        settings.ageGroup = selectedAgeGroup
        settings.themeMode = selectedTheme
        settings.hasAcceptedDisclaimer = hasAcceptedDisclaimer
        settings.disclaimerAcceptedDate = Date()
        settings.hasCompletedOnboarding = true
        settings.healthKitEnabled = healthKitEnabled
        settings.reminderEnabled = reminderEnabled
        settings.reminderHour = reminderHour
        settings.reminderMinute = reminderMinute

        do {
            try context.save()
        } catch {
            print("Error saving onboarding settings: \(error)")
        }
    }
}

#Preview {
    OnboardingContainerView()
        .modelContainer(for: [AppSettings.self], inMemory: true)
}
