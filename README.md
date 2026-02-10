<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS_18+-blue?style=for-the-badge&logo=apple" />
  <img src="https://img.shields.io/badge/Swift-6.0-orange?style=for-the-badge&logo=swift" />
  <img src="https://img.shields.io/badge/UI-SwiftUI-purple?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Data-SwiftData-green?style=for-the-badge" />
</p>

<h1 align="center">CORDIS</h1>

<p align="center">
  <strong>Monitoreo de frecuencia cardiaca y manejo de estres para jovenes</strong><br/>
  <em>Heart rate monitoring & stress management for young people</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/HealthKit-Integrated-red?style=flat-square" />
  <img src="https://img.shields.io/badge/CloudKit-Audio_Streaming-blue?style=flat-square" />
  <img src="https://img.shields.io/badge/Localization-ES_|_EN-yellow?style=flat-square" />
  <img src="https://img.shields.io/badge/Design-Glassmorphism-blueviolet?style=flat-square" />
</p>

---

## About

**CORDIS** is a native iOS app designed to help young people (ages 4-21) monitor their heart rate, understand stress patterns, and develop healthy habits through guided breathing exercises and meditations. Built entirely with **SwiftUI** and Apple's latest frameworks.

> Developed as part of an iOS Bootcamp at **Colegio Walden Dos de Mexico**.

---

## Features

### Heart Rate Monitoring
- **HealthKit integration** - Read real-time BPM from Apple Watch
- **Manual input** - Quick BPM entry with validation and shake feedback
- **Guided measurement** - 3-step process with animated wrist guide and 15-second countdown
- **Age-appropriate classification** - Stress levels calibrated per age group (4-7, 8-12, 13-16, 17-21)

### Statistics & Insights
- **Interactive charts** - BPM trends over time with gradient fills (Swift Charts)
- **Period filtering** - Weekly, monthly, and all-time views
- **Key metrics** - Average, min, max BPM at a glance
- **Streak tracking** - Consecutive daily measurements to build consistency

### Health Assistant
- **50 context-aware FAQs** across 8 categories (stress, exams, sleep, caffeine, exercise, stats, streaks, general)
- **Dynamic responses** - Answers incorporate the user's name, last BPM, 7-day average, and streak
- **Persistent chat history** - Conversations saved via SwiftData

### Guided Meditations
- **CloudKit-powered** - Audio content delivered from iCloud public database
- **Local caching** - Downloaded audio persists across sessions with version tracking
- **Real-time visualization** - Pulsing circle synced to audio amplitude
- **Haptic feedback** - CoreHaptics engine synchronized with audio playback
- **Background audio** - Continue listening when the app is in the background

### 4-7-8 Breathing Exercise
- Guided breathing with visual countdown timer
- Calming animated background

### Onboarding
- 7-step guided setup: welcome, disclaimer, profile, HealthKit, notifications, theme, completion
- Confetti celebration on completion

---

## Architecture

```
cordis/
├── App/                    # App entry point & root navigation
├── Views/                  # 15+ SwiftUI screens
│   └── Onboarding/         # 7-step onboarding flow
├── Components/             # Reusable glassmorphism UI kit
├── Models/                 # SwiftData models
├── Services/               # Business logic & integrations
└── Resources/              # Assets, localization, config
```

### Design System — Glassmorphism UI Kit

All UI components follow a consistent **glassmorphism** design language with adaptive Light/Dark mode support:

| Component | Description |
|-----------|-------------|
| `AnimatedGlassBackground` | Animated gradient with floating orbs (4 color schemes) |
| `GlassCard` / `GlassCardAccent` / `GlassCardDanger` | Frosted glass containers |
| `GlassButton` | Full-width button with 4 styles (primary, secondary, danger, success) |
| `GlassPillButton` | Compact filter/selection buttons |
| `GlassIconButton` | Circular icon buttons |

### Data Layer

| Framework | Purpose |
|-----------|---------|
| **SwiftData** | Local persistence (`StressEntry`, `UserStats`, `AppSettings`, `ChatMessage`) |
| **HealthKit** | Read-only heart rate data from Apple Health |
| **CloudKit** | Guided meditation audio storage & delivery |
| **UserNotifications** | Daily reminders & stress alerts |

### Key Patterns
- `@Observable` + `@Query` for reactive data binding
- `@Environment(\.modelContext)` for SwiftData operations
- `@Binding` for cross-view tab navigation
- `String(localized:)` with `.xcstrings` for bilingual support (es-419 / en)

---

## Tech Stack

| Technology | Usage |
|------------|-------|
| SwiftUI | Declarative UI with animations & transitions |
| SwiftData | Persistent storage with `@Query` bindings |
| HealthKit | Heart rate sensor data |
| CloudKit | Remote audio content delivery |
| Swift Charts | Statistical visualizations |
| AVFoundation | Audio playback & amplitude analysis |
| Accelerate | Real-time RMS audio processing |
| CoreHaptics | Synchronized haptic feedback |
| UserNotifications | Scheduled reminders |

---

## Localization

Fully bilingual app with **100+ localization keys**:

| Language | Coverage |
|----------|----------|
| Spanish (es-419) | Source language |
| English (en) | Full translation |

Includes localized FAQ content (50 questions + 50 answers), UI strings, stress classifications, and onboarding flows.

---

## Screenshots

> *Coming soon*

---

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 6.0
- Apple Developer account (for HealthKit & CloudKit)

## Getting Started

```bash
git clone https://github.com/ubaldoorozco/cordis.code.font.git
cd cordis.code.font
open cordis.xcodeproj
```

1. Select the `cordis` scheme
2. Choose a simulator or device
3. Build & Run

> **Note:** HealthKit features require a physical device. CloudKit requires an iCloud container configured as `iCloud.cordis`.

---

## Team

### Development
- Christian Arzaluz
- Ubaldo Orozco
- Santiago Aragoneses
- Hansel Ortega
- Patricio Aguilar
- Miguel Roldan

### Guided Meditations
- Janet Castillo
- Sarahi Serrano
- Isabel Alondra Castro

### Colegio Walden Dos de Mexico
- Eduardo Garcia

---

## License

This project was developed for educational purposes at Colegio Walden Dos de Mexico.

---

<p align="center">
  Built with SwiftUI
</p>
