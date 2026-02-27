import SwiftUI

struct ItemCounterView: View {
    let senseType: SenseType
    let filledCount: Int
    let totalCount: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(AppSettings.self) private var appSettings

    var body: some View {
        let base = appSettings.backgroundColor
        let darkShadow = Color.black.opacity(0.15)
        let lightShadow = Color.white.opacity(0.7)

        HStack(spacing: 10) {
            ForEach(0..<totalCount, id: \.self) { index in
                let isFilled = index < filledCount
                Circle()
                    .fill(isFilled
                        ? AnyShapeStyle(Color.senseGradient(for: senseType))
                        : AnyShapeStyle(base))
                    .frame(width: bubbleSize, height: bubbleSize)
                    .overlay(
                        Text("\(index + 1)")
                            .font(.system(size: bubbleSize * 0.4, weight: .bold, design: .rounded))
                            .foregroundStyle(isFilled ? .white : appSettings.colorTheme.secondaryText.opacity(0.5))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(isFilled ? 0.3 : 0.4), lineWidth: 0.5)
                    )
                    .scaleEffect(isFilled ? 1.0 : 0.85)
                    .shadow(
                        color: isFilled
                            ? Color.senseColor(for: senseType).opacity(0.4)
                            : darkShadow,
                        radius: isFilled ? 4 : bubbleSize * 0.1,
                        x: isFilled ? 0 : bubbleSize * 0.05,
                        y: isFilled ? 2 : bubbleSize * 0.05
                    )
                    .shadow(
                        color: isFilled ? .clear : lightShadow,
                        radius: bubbleSize * 0.1,
                        x: -bubbleSize * 0.04,
                        y: -bubbleSize * 0.04
                    )
                    .animation(
                        reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.6),
                        value: isFilled
                    )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(filledCount) of \(totalCount) items named")
        .accessibilityValue(filledCount == totalCount ? "Complete" : "In progress")
    }

    private var bubbleSize: CGFloat {
        switch totalCount {
        case 5: return 40
        case 4: return 44
        case 3: return 48
        case 2: return 52
        default: return 56
        }
    }
}
