//
//  MainTabView.swift
//  cordis
//
//  ubaldo orozco on 23/12/25
//  Updated with Medical Info tab
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showMedicalInfo = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(String(localized: "tab_home"), systemImage: "house.fill")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label(String(localized: "tab_history"), systemImage: "clock.arrow.circlepath")
                }
                .tag(1)

            StatsView()
                .tabItem {
                    Label(String(localized: "tab_stats"), systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)

            NavigationStack {
                GuidedMeditationListView()
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .tabItem {
                Label(String(localized: "tab_meditation"), systemImage: "headphones")
            }
            .tag(3)

            SettingsView()
                .tabItem {
                    Label(String(localized: "tab_settings"), systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(.purple)
    }
}

#Preview {
    MainTabView()
}
