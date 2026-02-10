//
//  CountdownTimerView.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct CountdownTimerView: View {
    let totalSeconds: Int
    let onComplete: () -> Void

    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var remainingSeconds: Int
    @State private var timer: Timer?
    @State private var isPulsing = false

    init(totalSeconds: Int = 15, onComplete: @escaping () -> Void) {
        self.totalSeconds = totalSeconds
        self.onComplete = onComplete
        self._remainingSeconds = State(initialValue: totalSeconds)
    }

    var progress: Double {
        Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }

    var body: some View {
        let circleSize: CGFloat = sizeClass == .regular ? 280 : 200

        VStack(spacing: 30) {
            // Circular progress
            ZStack {
                // Background ring
                Circle()
                    .stroke(
                        Color.white.opacity(0.2),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: circleSize, height: circleSize)

                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: circleSize, height: circleSize)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                // Center content
                VStack(spacing: 8) {
                    // Seconds display
                    Text("\(remainingSeconds)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .animation(.spring(duration: 0.3), value: remainingSeconds)

                    Text(String(localized: "timer_seconds"))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }

                // Pulsing heart
                Image(systemName: "heart.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.red)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .offset(y: 80)
            }

            // Instructions
            Text(String(localized: "timer_count_beats"))
                .font(.headline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(String(localized: "timer_feel_pulse"))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .onAppear {
            startTimer()
            startPulseAnimation()
        }
        .onDisappear {
            stopTimer()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
                triggerHaptic()
            }

            if remainingSeconds == 0 {
                stopTimer()
                triggerCompletionHaptic()
                onComplete()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
            isPulsing = true
        }
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    private func triggerCompletionHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Compact Timer

struct CompactCountdownTimer: View {
    let totalSeconds: Int
    @Binding var isActive: Bool
    let onComplete: () -> Void

    @State private var remainingSeconds: Int
    @State private var timer: Timer?

    init(totalSeconds: Int = 15, isActive: Binding<Bool>, onComplete: @escaping () -> Void) {
        self.totalSeconds = totalSeconds
        self._isActive = isActive
        self.onComplete = onComplete
        self._remainingSeconds = State(initialValue: totalSeconds)
    }

    var progress: Double {
        Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }

    var body: some View {
        HStack(spacing: 16) {
            // Mini circular progress
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 4)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.purple, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                Text("\(remainingSeconds)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "timer_counting"))
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(String(localized: "timer_count_each_beat"))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            Button {
                stopTimer()
                isActive = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onChange(of: isActive) { _, newValue in
            if newValue {
                remainingSeconds = totalSeconds
                startTimer()
            } else {
                stopTimer()
            }
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
                triggerHaptic()
            }

            if remainingSeconds == 0 {
                stopTimer()
                isActive = false
                onComplete()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Preview

#Preview("Full Timer") {
    ZStack {
        AnimatedGlassBackground(colorScheme: .calm)

        CountdownTimerView(totalSeconds: 15) {
            print("Timer complete!")
        }
    }
}

#Preview("Compact Timer") {
    ZStack {
        AnimatedGlassBackground(colorScheme: .calm)

        CompactCountdownTimer(totalSeconds: 15, isActive: .constant(true)) {
            print("Timer complete!")
        }
        .padding()
    }
}
