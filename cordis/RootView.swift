//
//  RootView.swift
//  cordis
//
//  Extracted by assistant on 23/12/25
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query private var settingsArr: [AppSettings]
    @Query private var statsArr: [UserStats]

    private var settings: AppSettings? { settingsArr.first }

    private var preferredScheme: ColorScheme? {
        switch settings?.themeMode ?? 0 {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }

    var body: some View {
        MainTabView()
            .preferredColorScheme(preferredScheme)
            .onAppear {
                ensureBootstrapData()
            }
    }

    private func ensureBootstrapData() {
        if settingsArr.isEmpty {
            context.insert(AppSettings())
        }
        if statsArr.isEmpty {
            context.insert(UserStats())
        }
        do { try context.save() } catch { print("SAVE ERROR (bootstrap):", error) }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [StressEntry.self, UserStats.self, AppSettings.self], inMemory: true)
}
