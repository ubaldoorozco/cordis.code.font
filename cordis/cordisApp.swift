import SwiftUI
import SwiftData

@main
struct CordisApp: App {
    private let container: ModelContainer = CordisPersistence.makeContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}

#Preview {
    RootView()
        .modelContainer(for: [StressEntry.self, UserStats.self, AppSettings.self], inMemory: true)
}
