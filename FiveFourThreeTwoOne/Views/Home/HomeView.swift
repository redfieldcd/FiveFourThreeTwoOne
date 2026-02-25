import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<Reflection> { $0.isComplete == true },
        sort: \Reflection.createdAt,
        order: .reverse
    )
    private var reflections: [Reflection]

    @State private var showingFlow = false
    @State private var showingSettings = false

    var body: some View {
        ZStack {
            if reflections.isEmpty {
                EmptyStateView()
            } else {
                reflectionList
            }

            newReflectionButton
        }
        .navigationTitle("5-4-3-2-1")
        .navigationDestination(isPresented: $showingFlow) {
            ReflectionFlowView()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Voice prompt settings")
            }
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                CustomPromptsView()
                    .navigationTitle("Voice Prompts")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showingSettings = false }
                        }
                    }
            }
        }
        .onAppear {
            BackgroundMusicService.shared.play()
        }
        .onDisappear {
            BackgroundMusicService.shared.stop()
        }
    }

    private var reflectionList: some View {
        List {
            ForEach(reflections) { reflection in
                NavigationLink(value: reflection) {
                    ReflectionRowView(reflection: reflection)
                }
            }
            .onDelete(perform: deleteReflections)

            // Extra space for the floating button
            Color.clear
                .frame(height: 80)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }

    private var newReflectionButton: some View {
        VStack {
            Spacer()
            Button {
                showingFlow = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("New Reflection")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Color.accentColor)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                )
            }
            .padding(.bottom, 24)
        }
    }

    private func deleteReflections(at offsets: IndexSet) {
        for index in offsets {
            let reflection = reflections[index]
            for entry in reflection.entries {
                if let url = entry.audioFileURL {
                    try? FileManager.default.removeItem(at: url)
                }
            }
            modelContext.delete(reflection)
        }
        try? modelContext.save()
    }
}
