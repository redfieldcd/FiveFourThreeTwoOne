import SwiftUI

struct ReflectionDetailView: View {
    @State var viewModel: ReflectionDetailViewModel

    init(reflection: Reflection, audioPlayer: any AudioPlaying = AudioPlaybackService()) {
        _viewModel = State(initialValue: ReflectionDetailViewModel(
            reflection: reflection, audioPlayer: audioPlayer
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection

                ForEach(viewModel.sortedEntries) { entry in
                    entryCard(entry)
                }
            }
            .padding()
        }
        .navigationTitle("Reflection")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.reflection.title)
                .font(.title2)
                .fontWeight(.bold)

            Text(viewModel.reflection.createdAt.journalFormatted)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func entryCard(_ entry: SenseEntry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SenseIconView(senseType: entry.senseType, size: 36)

                VStack(alignment: .leading) {
                    Text("\(entry.senseType.count) thing(s) I could \(entry.senseType.displayName.lowercased())")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }

            Text(entry.transcribedText)
                .font(.body)
                .padding(.leading, 48)

            if entry.audioFileName != nil {
                AudioPlayerView(
                    isPlaying: viewModel.currentlyPlayingEntryID === entry,
                    senseType: entry.senseType,
                    onPlay: {
                        try? viewModel.playAudio(for: entry)
                    },
                    onStop: {
                        viewModel.stopAudio()
                    }
                )
                .padding(.leading, 48)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}
