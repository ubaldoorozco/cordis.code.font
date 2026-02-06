//
//  cordisUITestsLaunchTests.swift
//  cordisUITests
//
//  Created by Balo Orozco on 23/12/25.
//  Launch and Screenshot Tests for CORDIS App
//

import XCTest

final class cordisUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Launch Screenshot Tests

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testHomeScreenScreenshot() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--skip-onboarding"]
        app.launch()

        // Wait for app to be ready
        _ = app.wait(for: .runningForeground, timeout: 10)

        // Complete onboarding if shown
        completeOnboardingIfNeeded(app: app)

        // Navigate to home
        let homeTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Home' OR label CONTAINS[c] 'Inicio'")).firstMatch
        if homeTab.waitForExistence(timeout: 5) {
            homeTab.tap()
        }

        sleep(2)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Home Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testHistoryScreenScreenshot() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--skip-onboarding"]
        app.launch()

        _ = app.wait(for: .runningForeground, timeout: 10)
        completeOnboardingIfNeeded(app: app)

        // Navigate to history
        let historyTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'History' OR label CONTAINS[c] 'Historial'")).firstMatch
        if historyTab.waitForExistence(timeout: 5) {
            historyTab.tap()
        }

        sleep(2)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "History Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testStatsScreenScreenshot() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--skip-onboarding"]
        app.launch()

        _ = app.wait(for: .runningForeground, timeout: 10)
        completeOnboardingIfNeeded(app: app)

        // Navigate to stats
        let statsTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Stats' OR label CONTAINS[c] 'Estadísticas'")).firstMatch
        if statsTab.waitForExistence(timeout: 5) {
            statsTab.tap()
        }

        sleep(2)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Stats Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testMeditationScreenScreenshot() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--skip-onboarding"]
        app.launch()

        _ = app.wait(for: .runningForeground, timeout: 10)
        completeOnboardingIfNeeded(app: app)

        // Navigate to meditation
        let meditationTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Meditation' OR label CONTAINS[c] 'Meditación'")).firstMatch
        if meditationTab.waitForExistence(timeout: 5) {
            meditationTab.tap()
        }

        sleep(2)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Meditation Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testSettingsScreenScreenshot() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--skip-onboarding"]
        app.launch()

        _ = app.wait(for: .runningForeground, timeout: 10)
        completeOnboardingIfNeeded(app: app)

        // Navigate to settings
        let settingsTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Ajustes'")).firstMatch
        if settingsTab.waitForExistence(timeout: 5) {
            settingsTab.tap()
        }

        sleep(2)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Settings Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testAboutScreenScreenshot() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--skip-onboarding"]
        app.launch()

        _ = app.wait(for: .runningForeground, timeout: 10)
        completeOnboardingIfNeeded(app: app)

        // Navigate to settings
        let settingsTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Ajustes'")).firstMatch
        if settingsTab.waitForExistence(timeout: 5) {
            settingsTab.tap()
        }

        sleep(2)

        // Scroll to find About button
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
            scrollView.swipeUp()
        }

        // Tap About button
        let aboutButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'About' OR label CONTAINS[c] 'Acerca'")).firstMatch
        if aboutButton.waitForExistence(timeout: 3) && aboutButton.isHittable {
            aboutButton.tap()
        }

        sleep(2)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "About Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testPrivacyPolicyScreenScreenshot() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--skip-onboarding"]
        app.launch()

        _ = app.wait(for: .runningForeground, timeout: 10)
        completeOnboardingIfNeeded(app: app)

        // Navigate to settings
        let settingsTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Ajustes'")).firstMatch
        if settingsTab.waitForExistence(timeout: 5) {
            settingsTab.tap()
        }

        sleep(2)

        // Scroll to find Privacy Policy button
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
            scrollView.swipeUp()
        }

        // Tap Privacy Policy button
        let privacyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Privacy' OR label CONTAINS[c] 'Privacidad'")).firstMatch
        if privacyButton.waitForExistence(timeout: 3) && privacyButton.isHittable {
            privacyButton.tap()
        }

        sleep(2)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Privacy Policy Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // MARK: - Onboarding Screenshots

    @MainActor
    func testOnboardingWelcomeScreenshot() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-state"]
        app.launch()

        _ = app.wait(for: .runningForeground, timeout: 10)

        // Wait for welcome screen
        let cordisText = app.staticTexts["CORDIS"]
        if cordisText.waitForExistence(timeout: 5) {
            sleep(1)

            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = "Onboarding Welcome"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }

    // MARK: - Dark Mode Screenshots

    @MainActor
    func testDarkModeHomeScreenshot() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--skip-onboarding"]
        app.launch()

        _ = app.wait(for: .runningForeground, timeout: 10)
        completeOnboardingIfNeeded(app: app)

        // Navigate to settings first to set dark mode
        let settingsTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Ajustes'")).firstMatch
        if settingsTab.waitForExistence(timeout: 5) {
            settingsTab.tap()
        }

        sleep(2)

        // Scroll to find theme picker
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
        }

        // Select dark theme
        let darkTheme = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Dark' OR label CONTAINS[c] 'Oscuro'")).firstMatch
        if darkTheme.waitForExistence(timeout: 3) && darkTheme.isHittable {
            darkTheme.tap()
        }

        sleep(1)

        // Navigate back to home
        let homeTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Home' OR label CONTAINS[c] 'Inicio'")).firstMatch
        if homeTab.waitForExistence(timeout: 5) {
            homeTab.tap()
        }

        sleep(2)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Home Screen Dark Mode"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // MARK: - Helper Methods

    private func completeOnboardingIfNeeded(app: XCUIApplication) {
        // If onboarding is showing, complete it
        for _ in 0..<10 {
            let continueButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Continuar' OR label CONTAINS[c] 'Continue' OR label CONTAINS[c] 'Siguiente' OR label CONTAINS[c] 'Next' OR label CONTAINS[c] 'Skip' OR label CONTAINS[c] 'Omitir' OR label CONTAINS[c] 'Comenzar' OR label CONTAINS[c] 'Start'")).firstMatch

            // Handle disclaimer checkbox if present
            let checkbox = app.switches.firstMatch
            if checkbox.exists && checkbox.isHittable {
                checkbox.tap()
                sleep(1)
            }

            if continueButton.exists && continueButton.isHittable {
                continueButton.tap()
                sleep(1)
            } else {
                break
            }

            // Check if we're at the main tab view
            if app.tabBars.firstMatch.exists {
                break
            }
        }
    }
}
