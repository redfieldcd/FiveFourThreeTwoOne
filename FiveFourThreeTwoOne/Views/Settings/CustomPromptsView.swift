import SwiftUI

struct CustomPromptsView: View {
    @Environment(AppSettings.self) private var appSettings
    @State private var viewModel = CustomPromptsViewModel()
    @State private var showingDeleteConfirmation = false
    @State private var senseToDelete: SenseType?

    var body: some View {
        @Bindable var settings = appSettings

        List {
            // MARK: - Color Theme
            Section {
                HStack(spacing: 12) {
                    ForEach(AppSettings.ColorTheme.allCases) { theme in
                        ThemeOptionView(
                            theme: theme,
                            isSelected: settings.colorTheme == theme
                        ) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                settings.colorTheme = theme
                            }
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
            } header: {
                Text("Color Theme")
            }

            // MARK: - Voice Prompts
            Section {
                ForEach(SenseType.orderedCases) { senseType in
                    CustomPromptRow(
                        senseType: senseType,
                        state: viewModel.promptStates[senseType] ?? .none,
                        onRecord: { viewModel.startRecording(for: senseType) },
                        onStopRecording: { viewModel.stopRecording() },
                        onPlay: { viewModel.playPrompt(for: senseType) },
                        onStopPlayback: { viewModel.stopPlayback() },
                        onDelete: {
                            senseToDelete = senseType
                            showingDeleteConfirmation = true
                        }
                    )
                }
            } header: {
                Text("Voice Prompts")
            } footer: {
                Text("Record a custom voice prompt for each sense. During a reflection, your recorded prompt will play instead of the default computer voice.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .alert("Delete Prompt?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let senseType = senseToDelete {
                    viewModel.deletePrompt(for: senseType)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let senseType = senseToDelete {
                Text("This will remove your custom \(senseType.displayName) prompt and revert to the default voice.")
            }
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}

// MARK: - Theme Option Card

private struct ThemeOptionView: View {
    let theme: AppSettings.ColorTheme
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Color preview circle
                ZStack {
                    Circle()
                        .fill(theme.backgroundColor)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .stroke(theme == .defaultWhite
                                    ? Color(.systemGray4)
                                    : theme.backgroundColor.opacity(0.5),
                                    lineWidth: 1)
                        )

                    Image(systemName: theme.iconName)
                        .font(.system(size: 20))
                        .foregroundStyle(theme.accentColor)
                }

                Text(theme.label)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
