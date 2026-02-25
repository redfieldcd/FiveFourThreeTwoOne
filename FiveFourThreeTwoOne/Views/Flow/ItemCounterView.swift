import SwiftUI

struct ItemCounterView: View {
    let senseType: SenseType
    let filledCount: Int
    let totalCount: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<totalCount, id: \.self) { index in
                let isFilled = index < filledCount
                Circle()
                    .fill(isFilled
                        ? AnyShapeStyle(Color.senseGradient(for: senseType))
                        : AnyShapeStyle(Color(.systemGray5)))
                    .frame(width: bubbleSize, height: bubbleSize)
                    .overlay(
                        Text("\(index + 1)")
                            .font(.system(size: bubbleSize * 0.4, weight: .bold, design: .rounded))
                            .foregroundStyle(isFilled ? .white : .gray)
                    )
                    .scaleEffect(isFilled ? 1.0 : 0.85)
                    .shadow(
                        color: isFilled
                            ? Color.senseColor(for: senseType).opacity(0.4)
                            : .clear,
                        radius: 4, y: 2
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
