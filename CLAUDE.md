# CLAUDE.md — CORDIS Project Context

This file provides context for Claude Code (or any AI assistant) working on the CORDIS iOS project.

## Project Overview

CORDIS is a native iOS app for heart rate monitoring and stress management, targeting young people (ages 4-21). It uses a glassmorphism design system and is fully bilingual (Spanish es-419 / English).

## Build & Run

- **Scheme:** `cordis`
- **Simulator:** `iPhone 17 Pro, OS=26.2`
- **Build command:**
  ```bash
  xcodebuild -scheme cordis -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2' build
  ```
- **SourceKit false positives:** Errors like "Cannot find 'StressEntry' in scope" from SourceKit indexing are false positives. Always verify with an actual build.

## Project Structure

```
cordis/
├── App/                    cordisApp.swift, RootView.swift
├── Views/                  15+ screens (Home, History, Stats, Meditation, Settings, etc.)
│   └── Onboarding/         7-step onboarding flow
├── Components/             Glassmorphism UI kit (GlassCard, GlassButton, AnimatedGlassBackground, etc.)
├── Models/                 Models.swift (StressEntry, UserStats, AppSettings, ChatMessage)
├── Services/               HealthKitManager, CloudKitService, NotificationManager, HapticManager, AudioAnalysisEngine
└── Resources/
    ├── Assets.xcassets/
    ├── localizable/Localizable.xcstrings   (~5500 lines, 360+ keys)
    └── Info.plist
```

## Key Frameworks

- **SwiftUI** — All UI
- **SwiftData** — Local persistence (`@Query`, `@Environment(\.modelContext)`)
- **HealthKit** — Read-only heart rate from Apple Health
- **CloudKit** — Guided meditation audio (container: `iCloud.cordis`, record type: `GuidedMeditation`)
- **Swift Charts** — BPM statistics visualization
- **AVFoundation + Accelerate** — Audio playback with amplitude analysis
- **CoreHaptics** — Haptic feedback during meditation
- **UserNotifications** — Daily reminders

## Localization

- Source language: `es-419` (Latin American Spanish)
- Translations: `en` (English)
- File: `cordis/Resources/localizable/Localizable.xcstrings` (JSON format)
- Pattern: `String(localized: "key")` for simple strings
- Interpolation: `String(localized: "key \(val)")` generates xcstrings key `"key %@"` with positional `%1$@` in values
- Integer interpolation uses `%lld`

## Design System

- **AnimatedGlassBackground** adapts to Light/Dark mode (pastel gradients in Light, deep gradients in Dark)
- Use `.primary` / `.secondary` for text colors — they adapt to the background
- Navigation bars use `.toolbarBackground(.ultraThinMaterial, for: .navigationBar)`
- Glass cards use `.ultraThinMaterial` backgrounds with `.primary.opacity()` borders

## Coding Patterns

- `@Binding var selectedTab: Int` for cross-tab navigation (HomeView, StatsView)
- `#if os(iOS)` view modifier blocks must stay chained to their parent view
- Previews use `.constant()` for `@Binding` params
- SwiftData models: `StressEntry`, `UserStats`, `AppSettings`, `ChatMessage`

## What Has Been Implemented

### Glassmorphism UI System
- AnimatedGlassBackground with 4 color schemes (calm, stress, success, neutral)
- Adaptive Light/Dark mode with pastel gradients in Light mode
- GlassCard, GlassCardAccent, GlassCardDanger containers
- GlassButton with primary/secondary/danger/success styles
- GlassPillButton for filters, GlassIconButton for circular buttons

### Home Screen (HomeView.swift)
- BPM input with validation (range 30-220) and shake animation on error
- HealthKit card with refresh and manual save button (visual confirmation)
- Quick actions: History navigation, Manual Measurement, Meditation, Health Assistant
- Stress level classification by age group with color-coded display
- Emergency meditation shortcut for high BPM (>120)

### History (HistoryView.swift)
- Filterable list of BPM entries (7 days, 30 days, 1 year, all)
- Swipe-to-delete entries
- Color-coded stress indicators

### Statistics (StatsView.swift)
- Average, min, max BPM cards
- Interactive line chart with gradient area fill (Swift Charts)
- Period selector (week, month, all)
- Total entries card navigates to History tab
- Chat button opens Health Assistant

### Health Assistant (HealthAssistantView.swift)
- 50 localized FAQs in 8 categories
- Context-aware answers with user data (name, BPM, average, streak)
- Persistent chat history via SwiftData
- Summary card with current stats
- Vertical-only scroll, fixed layout

### Guided Meditations
- CloudKit-powered audio content with local caching
- Localized numbered titles (Meditación 1 / Meditation 1)
- Support for `description_en` CloudKit field with fallback
- Audio player with pulsing visualization, haptic feedback, seek controls

### Manual Measurement (ManualMeasurementView.swift)
- 3-step flow: tutorial → 15s timer → beat counter
- Animated palm-up wrist guide with radial artery pulse indicator
- Quick-select buttons (10, 15, 20, 25 beats)
- BPM calculation (beats × 4) with result sheet

### 4-7-8 Breathing (MeditationView.swift)
- Guided breathing exercise with visual countdown

### Settings (SettingsView.swift)
- Profile (name, age group)
- Appearance (system/light/dark)
- Daily reminder scheduling
- HealthKit connection
- Chat history management
- Links to Medical Info, About, Privacy Policy

### Onboarding (7 steps)
- Welcome, Disclaimer, Profile, HealthKit, Notifications, Theme, Completion
- Confetti animation on completion

### Credits (AboutView.swift)
- Three sections: Development, Guided Meditations, Colegio Walden Dos de Mexico
- Avatar circles with initials

### Full Localization
- 360+ keys in Localizable.xcstrings
- 50 FAQ questions + 50 FAQ answers fully translated
- All UI strings bilingual
- Navigation titles, buttons, placeholders, error messages

## Common Pitfalls

- When inserting conditional views in SwiftUI ViewBuilder, keep chained modifiers (like `.toolbar`) attached to their view BEFORE inserting new conditional blocks
- xcstrings key format for interpolation: `"key %@ %@ %lld"` with positional `%1$@`, `%2$@`, `%3$lld` in values
- The xcstrings file is large (~5500 lines). Always read before editing and verify JSON validity.
- SourceKit indexing errors are false positives — always verify with `xcodebuild`
