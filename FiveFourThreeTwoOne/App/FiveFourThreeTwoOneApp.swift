import SwiftUI
import SwiftData

@main
struct FiveFourThreeTwoOneApp: App {
    @State private var appSettings = AppSettings()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
                    .navigationDestination(for: Reflection.self) { reflection in
                        ReflectionDetailView(reflection: reflection)
                    }
            }
            .environment(appSettings)
            .preferredColorScheme(appSettings.colorScheme)
            .tint(appSettings.themeAccentColor)
        }
        .modelContainer(for: [Reflection.self, SenseEntry.self])
    }
}
