//
//  MainTabView.swift
//  cordis
//
//  Extracted by assistant on 23/12/25
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Inicio", systemImage: "house.fill") }

            HistoryView()
                .tabItem { Label("Historial", systemImage: "clock.arrow.circlepath") }

            StatsView()
                .tabItem { Label("Estadísticas", systemImage: "chart.line.uptrend.xyaxis") }

            SettingsView()
                .tabItem { Label("Ajustes", systemImage: "gearshape.fill") }
        }
        .tint(.orange)
    }
}

#Preview {
    MainTabView()
}


