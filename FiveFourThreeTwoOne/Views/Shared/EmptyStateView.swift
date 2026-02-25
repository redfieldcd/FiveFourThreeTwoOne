import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green.opacity(0.6))

            Text("No reflections yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Tap the button below to start your first 5-4-3-2-1 grounding exercise.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
}
