import SwiftUI

struct ProgressStepIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Circle()
                    .fill(fillColor(for: index))
                    .frame(width: dotSize(for: index), height: dotSize(for: index))
                    .overlay {
                        if index == currentStep {
                            Circle()
                                .stroke(Color.senseColor(for: SenseType.orderedCases[index]), lineWidth: 2)
                                .frame(width: 16, height: 16)
                        }
                    }
                    .animation(.spring(response: 0.3), value: currentStep)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(currentStep + 1) of \(totalSteps)")
        .accessibilityValue(SenseType.orderedCases[currentStep].displayName)
    }

    private func fillColor(for index: Int) -> Color {
        if index < currentStep {
            return Color.senseColor(for: SenseType.orderedCases[index])
        } else if index == currentStep {
            return Color.senseColor(for: SenseType.orderedCases[index])
        } else {
            return Color.gray.opacity(0.3)
        }
    }

    private func dotSize(for index: Int) -> CGFloat {
        index == currentStep ? 12 : 8
    }
}
