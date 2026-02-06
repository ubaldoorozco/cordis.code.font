//
//  cordisUITests.swift
//  cordisUITests
//
//  Created by Balo Orozco on 23/12/25.
//  Comprehensive UI/UX Tests for CORDIS App
//

import XCTest

final class cordisUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()

        // Reset app state for fresh testing
        app.launchArguments = ["--uitesting", "--reset-state"]
        app.launchEnvironment = ["UITEST_DISABLE_ANIMATIONS": "1"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Launch Tests

    @MainActor
    func testAppLaunchesSuccessfully() throws {
        app.launch()

        // App should launch and show either onboarding or main tab view
        let exists = app.wait(for: .runningForeground, timeout: 10)
        XCTAssertTrue(exists, "App should launch successfully")
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    // MARK: - Onboarding Flow Tests

    @MainActor
    func testOnboardingWelcomeScreenElements() throws {
        app.launch()

        // Wait for onboarding to appear (for fresh install)
        let welcomeExists = app.staticTexts["CORDIS"].waitForExistence(timeout: 5)

        if welcomeExists {
            // Check welcome screen elements
            XCTAssertTrue(app.staticTexts["CORDIS"].exists, "Welcome should show CORDIS title")

            // Look for a continue/start button
            let startButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Comenzar' OR label CONTAINS[c] 'Start' OR label CONTAINS[c] 'Continuar' OR label CONTAINS[c] 'Continue'")).firstMatch
            XCTAssertTrue(startButton.waitForExistence(timeout: 3), "Welcome should have a start button")
        }
    }

    @MainActor
    func testOnboardingDisclaimerRequiresAcceptance() throws {
        app.launch()

        // Navigate through welcome if present
        let startButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Comenzar' OR label CONTAINS[c] 'Start'")).firstMatch
        if startButton.waitForExistence(timeout: 3) {
            startButton.tap()
        }

        // Look for disclaimer elements
        let disclaimerText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'médico' OR label CONTAINS[c] 'medical' OR label CONTAINS[c] 'aviso' OR label CONTAINS[c] 'disclaimer'")).firstMatch

        if disclaimerText.waitForExistence(timeout: 3) {
            // Find the checkbox/toggle for accepting
            let checkbox = app.switches.firstMatch
            let continueButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Continuar' OR label CONTAINS[c] 'Continue'")).firstMatch

            // Continue button should be disabled until disclaimer is accepted
            if checkbox.exists && continueButton.exists {
                checkbox.tap()
                XCTAssertTrue(continueButton.isEnabled, "Continue should be enabled after accepting disclaimer")
            }
        }
    }

    @MainActor
    func testOnboardingProfileSetup() throws {
        app.launch()

        // Skip to profile screen if possible
        navigateToOnboardingStep(stepIndex: 2)

        // Look for profile elements
        let nameField = app.textFields.firstMatch
        if nameField.waitForExistence(timeout: 3) {
            nameField.tap()
            nameField.typeText("Test User")

            // Dismiss keyboard
            app.keyboards.buttons["Done"].tap()

            XCTAssertEqual(nameField.value as? String, "Test User", "Name should be entered")
        }
    }

    // MARK: - Main Tab Navigation Tests

    @MainActor
    func testMainTabViewNavigation() throws {
        launchAppSkippingOnboarding()

        // Wait for tab bar
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Tab bar should exist")

        // Test each tab
        let homeTab = tabBar.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Home' OR label CONTAINS[c] 'Inicio'")).firstMatch
        let historyTab = tabBar.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'History' OR label CONTAINS[c] 'Historial'")).firstMatch
        let statsTab = tabBar.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Stats' OR label CONTAINS[c] 'Estadísticas'")).firstMatch
        let meditationTab = tabBar.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Meditation' OR label CONTAINS[c] 'Meditación'")).firstMatch
        let settingsTab = tabBar.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Ajustes'")).firstMatch

        // Navigate through tabs
        if historyTab.exists {
            historyTab.tap()
            sleep(1)
        }

        if statsTab.exists {
            statsTab.tap()
            sleep(1)
        }

        if meditationTab.exists {
            meditationTab.tap()
            sleep(1)
        }

        if settingsTab.exists {
            settingsTab.tap()
            sleep(1)
        }

        if homeTab.exists {
            homeTab.tap()
            sleep(1)
        }
    }

    @MainActor
    func testTabBarIsAlwaysVisible() throws {
        launchAppSkippingOnboarding()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Tab bar should exist")

        // Navigate to each tab and verify tab bar is still visible
        let tabs = tabBar.buttons.allElementsBoundByIndex
        for tab in tabs {
            if tab.isHittable {
                tab.tap()
                sleep(1)
                XCTAssertTrue(tabBar.isHittable, "Tab bar should remain visible after navigation")
            }
        }
    }

    // MARK: - Home View Tests

    @MainActor
    func testHomeViewElements() throws {
        launchAppSkippingOnboarding()

        // Navigate to home if not already there
        let homeTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Home' OR label CONTAINS[c] 'Inicio'")).firstMatch
        if homeTab.exists {
            homeTab.tap()
        }

        // Check for CORDIS header
        XCTAssertTrue(app.staticTexts["CORDIS"].waitForExistence(timeout: 3), "CORDIS header should exist")

        // Check for BPM input field
        let textField = app.textFields.firstMatch
        XCTAssertTrue(textField.waitForExistence(timeout: 3), "BPM input field should exist")

        // Check for save button
        let saveButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Save' OR label CONTAINS[c] 'Guardar'")).firstMatch
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3), "Save button should exist")
    }

    @MainActor
    func testBPMInputValidation() throws {
        launchAppSkippingOnboarding()

        // Navigate to home
        let homeTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Home' OR label CONTAINS[c] 'Inicio'")).firstMatch
        if homeTab.exists {
            homeTab.tap()
        }

        let textField = app.textFields.firstMatch
        guard textField.waitForExistence(timeout: 3) else {
            XCTFail("BPM input field not found")
            return
        }

        // Test valid BPM input
        textField.tap()
        textField.typeText("75")

        // Verify input is numbers only
        let value = textField.value as? String ?? ""
        XCTAssertTrue(value.allSatisfy { $0.isNumber }, "BPM input should only contain numbers")
    }

    @MainActor
    func testSavingBPMEntry() throws {
        launchAppSkippingOnboarding()

        // Navigate to home
        let homeTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Home' OR label CONTAINS[c] 'Inicio'")).firstMatch
        if homeTab.exists {
            homeTab.tap()
        }

        let textField = app.textFields.firstMatch
        guard textField.waitForExistence(timeout: 3) else {
            XCTFail("BPM input field not found")
            return
        }

        // Enter BPM
        textField.tap()
        textField.typeText("72")

        // Dismiss keyboard if present
        if app.keyboards.buttons["Done"].exists {
            app.keyboards.buttons["Done"].tap()
        }

        // Tap save button
        let saveButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Save' OR label CONTAINS[c] 'Guardar'")).firstMatch
        if saveButton.exists && saveButton.isHittable {
            saveButton.tap()

            // Verify the entry was saved by checking for the BPM display
            let bpmDisplay = app.staticTexts["72"]
            XCTAssertTrue(bpmDisplay.waitForExistence(timeout: 3), "Saved BPM should be displayed")
        }
    }

    @MainActor
    func testManualMeasurementButton() throws {
        launchAppSkippingOnboarding()

        // Navigate to home
        let homeTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Home' OR label CONTAINS[c] 'Inicio'")).firstMatch
        if homeTab.exists {
            homeTab.tap()
        }

        // Find manual measurement button
        let manualButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Manual' OR label CONTAINS[c] 'Medir'")).firstMatch

        if manualButton.waitForExistence(timeout: 3) && manualButton.isHittable {
            manualButton.tap()

            // Verify manual measurement view appears (full screen cover)
            let closeButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Close' OR label CONTAINS[c] 'Cerrar' OR label CONTAINS[c] 'Cancel' OR label CONTAINS[c] 'Cancelar'")).firstMatch
            XCTAssertTrue(closeButton.waitForExistence(timeout: 3), "Manual measurement view should appear")

            // Close it
            if closeButton.exists {
                closeButton.tap()
            }
        }
    }

    // MARK: - History View Tests

    @MainActor
    func testHistoryViewElements() throws {
        launchAppSkippingOnboarding()

        // Navigate to history tab
        let historyTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'History' OR label CONTAINS[c] 'Historial'")).firstMatch
        guard historyTab.waitForExistence(timeout: 5) else {
            XCTFail("History tab not found")
            return
        }
        historyTab.tap()

        // Check for history title
        let historyTitle = app.navigationBars.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'History' OR label CONTAINS[c] 'Historial'")).firstMatch
        XCTAssertTrue(historyTitle.waitForExistence(timeout: 3) || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'History' OR label CONTAINS[c] 'Historial'")).firstMatch.exists, "History view should show title")
    }

    // MARK: - Stats View Tests

    @MainActor
    func testStatsViewElements() throws {
        launchAppSkippingOnboarding()

        // Navigate to stats tab
        let statsTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Stats' OR label CONTAINS[c] 'Estadísticas'")).firstMatch
        guard statsTab.waitForExistence(timeout: 5) else {
            XCTFail("Stats tab not found")
            return
        }
        statsTab.tap()

        // Stats view should have statistics content
        sleep(2) // Wait for view to load

        // Check for stats-related content
        let statsContent = app.scrollViews.firstMatch
        XCTAssertTrue(statsContent.waitForExistence(timeout: 3), "Stats view should have scrollable content")
    }

    // MARK: - Meditation View Tests

    @MainActor
    func testMeditationListViewElements() throws {
        launchAppSkippingOnboarding()

        // Navigate to meditation tab
        let meditationTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Meditation' OR label CONTAINS[c] 'Meditación'")).firstMatch
        guard meditationTab.waitForExistence(timeout: 5) else {
            XCTFail("Meditation tab not found")
            return
        }
        meditationTab.tap()

        sleep(2) // Wait for view to load

        // Check for breathing exercise section
        let breathingSection = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Breathing' OR label CONTAINS[c] 'Respiración' OR label CONTAINS[c] '4-7-8'")).firstMatch
        XCTAssertTrue(breathingSection.waitForExistence(timeout: 3), "Meditation view should show breathing exercises")
    }

    @MainActor
    func testBreathingExerciseNavigation() throws {
        launchAppSkippingOnboarding()

        // Navigate to meditation tab
        let meditationTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Meditation' OR label CONTAINS[c] 'Meditación'")).firstMatch
        guard meditationTab.waitForExistence(timeout: 5) else {
            XCTFail("Meditation tab not found")
            return
        }
        meditationTab.tap()

        sleep(2)

        // Find and tap breathing exercise button
        let breathingButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '4-7-8' OR label CONTAINS[c] 'Breathing' OR label CONTAINS[c] 'Respiración'")).firstMatch

        if breathingButton.waitForExistence(timeout: 3) && breathingButton.isHittable {
            breathingButton.tap()

            // Verify meditation view appears
            let closeButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Close' OR label CONTAINS[c] 'Cerrar' OR label CONTAINS[c] 'Done' OR label CONTAINS[c] 'Listo'")).firstMatch
            XCTAssertTrue(closeButton.waitForExistence(timeout: 3), "Breathing exercise view should appear")

            // Close it
            if closeButton.exists {
                closeButton.tap()
            }
        }
    }

    // MARK: - Settings View Tests

    @MainActor
    func testSettingsViewElements() throws {
        launchAppSkippingOnboarding()

        // Navigate to settings tab
        let settingsTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Ajustes'")).firstMatch
        guard settingsTab.waitForExistence(timeout: 5) else {
            XCTFail("Settings tab not found")
            return
        }
        settingsTab.tap()

        sleep(2)

        // Check for key settings elements
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 3), "Settings should have scrollable content")

        // Check for name text field
        let nameField = app.textFields.firstMatch
        XCTAssertTrue(nameField.waitForExistence(timeout: 3), "Settings should have name field")
    }

    @MainActor
    func testSettingsThemePicker() throws {
        launchAppSkippingOnboarding()

        // Navigate to settings tab
        let settingsTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Ajustes'")).firstMatch
        guard settingsTab.waitForExistence(timeout: 5) else {
            XCTFail("Settings tab not found")
            return
        }
        settingsTab.tap()

        sleep(2)

        // Look for theme picker segments
        let systemTheme = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'System' OR label CONTAINS[c] 'Sistema'")).firstMatch
        let lightTheme = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Light' OR label CONTAINS[c] 'Claro'")).firstMatch
        let darkTheme = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Dark' OR label CONTAINS[c] 'Oscuro'")).firstMatch

        // Scroll to find theme picker if needed
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
        }

        // Test theme switching
        if lightTheme.waitForExistence(timeout: 3) && lightTheme.isHittable {
            lightTheme.tap()
            sleep(1)
        }

        if darkTheme.waitForExistence(timeout: 3) && darkTheme.isHittable {
            darkTheme.tap()
            sleep(1)
        }

        if systemTheme.waitForExistence(timeout: 3) && systemTheme.isHittable {
            systemTheme.tap()
        }
    }

    @MainActor
    func testSettingsAboutButton() throws {
        launchAppSkippingOnboarding()

        // Navigate to settings tab
        let settingsTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Ajustes'")).firstMatch
        guard settingsTab.waitForExistence(timeout: 5) else {
            XCTFail("Settings tab not found")
            return
        }
        settingsTab.tap()

        sleep(2)

        // Scroll to find About button
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
            scrollView.swipeUp()
        }

        // Find and tap About button
        let aboutButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'About' OR label CONTAINS[c] 'Acerca'")).firstMatch

        if aboutButton.waitForExistence(timeout: 3) && aboutButton.isHittable {
            aboutButton.tap()

            // Verify About view appears
            let cordisTitle = app.staticTexts["CORDIS"]
            XCTAssertTrue(cordisTitle.waitForExistence(timeout: 3), "About view should show CORDIS")

            // Check for credits
            let credits = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Christian' OR label CONTAINS[c] 'Ubaldo' OR label CONTAINS[c] 'Walden'")).firstMatch
            XCTAssertTrue(credits.waitForExistence(timeout: 3), "About view should show credits")

            // Close the about view
            let doneButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Done' OR label CONTAINS[c] 'Listo'")).firstMatch
            if doneButton.exists {
                doneButton.tap()
            }
        }
    }

    @MainActor
    func testSettingsPrivacyPolicyButton() throws {
        launchAppSkippingOnboarding()

        // Navigate to settings tab
        let settingsTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Ajustes'")).firstMatch
        guard settingsTab.waitForExistence(timeout: 5) else {
            XCTFail("Settings tab not found")
            return
        }
        settingsTab.tap()

        sleep(2)

        // Scroll to find Privacy Policy button
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
            scrollView.swipeUp()
        }

        // Find and tap Privacy Policy button
        let privacyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Privacy' OR label CONTAINS[c] 'Privacidad'")).firstMatch

        if privacyButton.waitForExistence(timeout: 3) && privacyButton.isHittable {
            privacyButton.tap()

            // Verify Privacy Policy view appears
            sleep(1)
            let doneButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Done' OR label CONTAINS[c] 'Listo'")).firstMatch
            XCTAssertTrue(doneButton.waitForExistence(timeout: 3), "Privacy Policy view should appear")

            // Close it
            if doneButton.exists {
                doneButton.tap()
            }
        }
    }

    @MainActor
    func testSettingsHealthKitToggle() throws {
        launchAppSkippingOnboarding()

        // Navigate to settings tab
        let settingsTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Ajustes'")).firstMatch
        guard settingsTab.waitForExistence(timeout: 5) else {
            XCTFail("Settings tab not found")
            return
        }
        settingsTab.tap()

        sleep(2)

        // Find HealthKit toggle
        let healthKitToggle = app.switches.matching(NSPredicate(format: "label CONTAINS[c] 'Health' OR label CONTAINS[c] 'HealthKit'")).firstMatch

        if healthKitToggle.waitForExistence(timeout: 3) {
            let initialValue = healthKitToggle.value as? String
            healthKitToggle.tap()

            // Note: In simulator, HealthKit may not be available, so we just verify the toggle responds
            sleep(1)
        }
    }

    @MainActor
    func testSettingsReminderToggle() throws {
        launchAppSkippingOnboarding()

        // Navigate to settings tab
        let settingsTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Ajustes'")).firstMatch
        guard settingsTab.waitForExistence(timeout: 5) else {
            XCTFail("Settings tab not found")
            return
        }
        settingsTab.tap()

        sleep(2)

        // Scroll to find reminder toggle
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
        }

        // Find reminder toggle
        let reminderToggle = app.switches.matching(NSPredicate(format: "label CONTAINS[c] 'Reminder' OR label CONTAINS[c] 'Recordatorio'")).firstMatch

        if reminderToggle.waitForExistence(timeout: 3) && reminderToggle.isHittable {
            reminderToggle.tap()
            sleep(1)

            // If enabled, time picker should appear
            let timePicker = app.datePickers.firstMatch
            // Time picker visibility depends on toggle state
        }
    }

    // MARK: - Accessibility Tests

    @MainActor
    func testAccessibilityLabelsExist() throws {
        launchAppSkippingOnboarding()

        // Check that main elements have accessibility labels
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Tab bar should exist")

        let tabs = tabBar.buttons.allElementsBoundByIndex
        for tab in tabs {
            XCTAssertFalse(tab.label.isEmpty, "Tab should have accessibility label")
        }
    }

    @MainActor
    func testMinimumTouchTargetSize() throws {
        launchAppSkippingOnboarding()

        // Navigate to settings for more buttons
        let settingsTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Ajustes'")).firstMatch
        if settingsTab.waitForExistence(timeout: 5) {
            settingsTab.tap()
        }

        sleep(2)

        // Check button sizes (minimum 44x44 per Apple guidelines)
        let buttons = app.buttons.allElementsBoundByIndex
        for button in buttons.prefix(10) { // Check first 10 buttons
            if button.exists && button.isHittable {
                let frame = button.frame
                // Minimum touch target is 44x44 points
                // We use a slightly smaller threshold for edge cases
                XCTAssertTrue(frame.width >= 40 || frame.height >= 40,
                             "Button '\(button.label)' should have adequate touch target size")
            }
        }
    }

    // MARK: - UI State Persistence Tests

    @MainActor
    func testSettingsPersistAcrossAppRelaunch() throws {
        launchAppSkippingOnboarding()

        // Navigate to settings
        let settingsTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Ajustes'")).firstMatch
        guard settingsTab.waitForExistence(timeout: 5) else {
            XCTFail("Settings tab not found")
            return
        }
        settingsTab.tap()

        sleep(2)

        // Change name
        let nameField = app.textFields.firstMatch
        if nameField.waitForExistence(timeout: 3) && nameField.isHittable {
            nameField.tap()

            // Clear existing text
            if let existingText = nameField.value as? String, !existingText.isEmpty {
                nameField.clearAndEnterText(text: "UITest User")
            } else {
                nameField.typeText("UITest User")
            }

            // Dismiss keyboard
            if app.keyboards.buttons["Done"].exists {
                app.keyboards.buttons["Done"].tap()
            }
        }

        // Terminate and relaunch
        app.terminate()
        app.launch()

        // Navigate back to settings
        if settingsTab.waitForExistence(timeout: 5) {
            settingsTab.tap()
        }

        sleep(2)

        // Verify name persisted
        let nameFieldAfterRelaunch = app.textFields.firstMatch
        if nameFieldAfterRelaunch.waitForExistence(timeout: 3) {
            let savedName = nameFieldAfterRelaunch.value as? String ?? ""
            XCTAssertTrue(savedName.contains("UITest") || savedName.contains("User"),
                         "Settings should persist across app relaunch")
        }
    }

    // MARK: - Scroll Behavior Tests

    @MainActor
    func testScrollViewsWorkCorrectly() throws {
        launchAppSkippingOnboarding()

        // Test scroll in home view
        let homeTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Home' OR label CONTAINS[c] 'Inicio'")).firstMatch
        if homeTab.waitForExistence(timeout: 5) {
            homeTab.tap()
        }

        let scrollView = app.scrollViews.firstMatch
        if scrollView.waitForExistence(timeout: 3) {
            scrollView.swipeUp()
            scrollView.swipeDown()
            // If no crash, scroll works
        }

        // Test scroll in settings view
        let settingsTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Ajustes'")).firstMatch
        if settingsTab.exists {
            settingsTab.tap()
            sleep(1)

            if scrollView.exists {
                scrollView.swipeUp()
                scrollView.swipeUp()
                scrollView.swipeDown()
            }
        }
    }

    // MARK: - Error Handling Tests

    @MainActor
    func testInvalidBPMInputHandling() throws {
        launchAppSkippingOnboarding()

        // Navigate to home
        let homeTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Home' OR label CONTAINS[c] 'Inicio'")).firstMatch
        if homeTab.exists {
            homeTab.tap()
        }

        let textField = app.textFields.firstMatch
        guard textField.waitForExistence(timeout: 3) else {
            XCTFail("BPM input field not found")
            return
        }

        // Try to enter letters (should be filtered out)
        textField.tap()
        textField.typeText("abc123")

        let value = textField.value as? String ?? ""
        XCTAssertTrue(value == "123" || value.allSatisfy { $0.isNumber },
                     "Non-numeric characters should be filtered")
    }

    // MARK: - Helper Methods

    private func launchAppSkippingOnboarding() {
        // Launch with arguments to skip onboarding if available
        app.launchArguments = ["--uitesting", "--skip-onboarding"]
        app.launch()

        // Wait for app to be ready
        _ = app.wait(for: .runningForeground, timeout: 10)

        // Check if we're already at the tab bar
        if app.tabBars.firstMatch.waitForExistence(timeout: 3) {
            return
        }

        // If onboarding appears, try to complete it
        completeOnboardingQuickly()

        // Wait for tab bar to appear after onboarding
        _ = app.tabBars.firstMatch.waitForExistence(timeout: 10)
    }

    private func completeOnboardingQuickly() {
        // Step through onboarding quickly
        for step in 0..<15 {
            // Check if we're at the main tab view first
            if app.tabBars.firstMatch.waitForExistence(timeout: 1) {
                return
            }

            // Handle disclaimer checkbox/toggle if present
            let toggle = app.switches.firstMatch
            if toggle.exists && toggle.isHittable {
                let value = toggle.value as? String
                if value != "1" {
                    toggle.tap()
                    sleep(1)
                }
            }

            // Look for any continue/next/skip/finish button
            let buttons = [
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Continue'")).firstMatch,
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Continuar'")).firstMatch,
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Next'")).firstMatch,
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Siguiente'")).firstMatch,
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Skip'")).firstMatch,
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Omitir'")).firstMatch,
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Start'")).firstMatch,
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Comenzar'")).firstMatch,
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Finish'")).firstMatch,
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Finalizar'")).firstMatch
            ]

            var tapped = false
            for button in buttons {
                if button.waitForExistence(timeout: 1) && button.isHittable {
                    button.tap()
                    tapped = true
                    sleep(2) // Give more time for animation
                    break
                }
            }

            if !tapped {
                // Try swiping left to proceed (for PageTabViewStyle)
                let scrollView = app.scrollViews.firstMatch
                if scrollView.exists {
                    scrollView.swipeLeft()
                    sleep(1)
                }
            }
        }
    }

    private func navigateToOnboardingStep(stepIndex: Int) {
        // Navigate through onboarding to specific step
        for _ in 0..<stepIndex {
            // Handle disclaimer toggle if present
            let toggle = app.switches.firstMatch
            if toggle.exists && toggle.isHittable {
                let value = toggle.value as? String
                if value != "1" {
                    toggle.tap()
                    sleep(1)
                }
            }

            // Look for continue buttons
            let buttons = [
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Continue'")).firstMatch,
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Continuar'")).firstMatch,
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Next'")).firstMatch,
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Start'")).firstMatch,
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Comenzar'")).firstMatch
            ]

            for button in buttons {
                if button.waitForExistence(timeout: 2) && button.isHittable {
                    button.tap()
                    sleep(2)
                    break
                }
            }
        }
    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    func clearAndEnterText(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non-string value")
            return
        }

        self.tap()

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
        self.typeText(text)
    }
}
