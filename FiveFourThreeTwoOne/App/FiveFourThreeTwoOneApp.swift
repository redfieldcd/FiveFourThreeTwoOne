import SwiftUI
import SwiftData

@main
struct FiveFourThreeTwoOneApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
                    .navigationDestination(for: Reflection.self) { reflection in
                        ReflectionDetailView(reflection: reflection)
                    }
            }
        }
        .modelContainer(for: [Reflection.self, SenseEntry.self])
    }
}
