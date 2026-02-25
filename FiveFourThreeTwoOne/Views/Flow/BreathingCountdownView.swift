import SwiftUI
import AVFoundation

/// Holds a strong reference to AVAudioPlayer so it doesn't get released.
private class BreathingAudioPlayer {
    var player: AVAudioPlayer?

    func play(resource: String, extension ext: String) {
        guard let url = Bundle.main.url(forResource: resource, withExtension: ext) else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = 1.0
            player?.prepareToPlay()
            player?.play()
        } catch {
            player = nil
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }
}

struct BreathingCountdownView: View {
    let onComplete: () -> Void

    @State private var countdown = 3
    @State private var ringProgress: CGFloat = 0
    @State private var textOpacity: Double = 1
    @State private var breathScale: CGFloat = 0.85
    @State private var audioPlayer = BreathingAudioPlayer()

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let circleSize: CGFloat = 200

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.accentColor.opacity(0.15), lineWidth: 6)
                    .frame(width: circleSize, height: circleSize)

                // Animated progress ring
                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: circleSize, height: circleSize)
                    .rotationEffect(.degrees(-90))

                // Breathing circle
                Circle()
                    .fill(Color.accentColor.opacity(0.08))
                    .frame(width: circleSize - 30, height: circleSize - 30)
                    .scaleEffect(breathScale)

                // Countdown number
                VStack(spacing: 8) {
                    Text("\(countdown)")
                        .font(.system(size: 64, weight: .light, design: .rounded))
                        .foregroundStyle(Color.accentColor)
                        .contentTransition(.numericText(countsDown: true))
                }
            }

            Text("Take a big breath")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .opacity(textOpacity)

            Spacer()
        }
        .onAppear {
            // Ensure background music is fully stopped before playing
            BackgroundMusicService.shared.stop()

            // Small delay to let audio session settle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                audioPlayer.play(resource: "lets_take_a_big_breath", extension: "mp3")
                startCountdown()
            }
        }
        .onDisappear {
            audioPlayer.stop()
        }
    }

    private func startCountdown() {
        // Breathing animation — gentle expand/contract
        if !reduceMotion {
            withAnimation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
            ) {
                breathScale = 1.0
            }
        }

        // Ring fills over 3 seconds
        withAnimation(.linear(duration: 3)) {
            ringProgress = 1.0
        }

        // Countdown: 3 → 2 → 1 → done
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.spring(response: 0.3)) {
                countdown = 2
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.spring(response: 0.3)) {
                countdown = 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeOut(duration: 0.3)) {
                textOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onComplete()
            }
        }
    }
}
