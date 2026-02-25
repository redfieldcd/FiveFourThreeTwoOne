import SwiftUI

struct ReflectionRowView: View {
    let reflection: Reflection

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(reflection.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(reflection.createdAt.relativeFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                senseIndicators
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
    }

    private var senseIndicators: some View {
        HStack(spacing: 4) {
            ForEach(SenseType.orderedCases) { senseType in
                let hasEntry = reflection.entries.contains { $0.senseType == senseType }
                Circle()
                    .fill(hasEntry ? Color.senseColor(for: senseType) : Color.gray.opacity(0.2))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
