//
//  MeditationView.swift
//  cordis
//
//  ubaldo orozco on 23/12/25
//  Redesigned with glassmorphism
//

import SwiftUI

struct MeditationView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var secondsLeft = 4 * 60
    @State private var faseText = ""
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var breatheScale: CGFloat = 0.8
    @State private var sessionComplete = false

    let fases: [(text: String, seconds: Int, key: String)] = [
        ("Inhala", 4, "meditation_inhale"),
        ("Mantén", 7, "meditation_hold"),
        ("Exhala", 8, "meditation_exhale"),
        ("Respira normal", 4, "meditation_breathe")
    ]
    @State private var faseIndex = 0

    var body: some View {
        ZStack {
            AnimatedGlassBackground(colorScheme: sessionComplete ? .success : .calm)

            VStack(spacing: 40) {
                // Header
                HStack {
                    Button {
                        timer?.invalidate()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }

                    Spacer()
                }
                .padding()

                Spacer()

                Text(String(localized: "meditation_title"))
                    .font(.title.bold())
                    .foregroundColor(.white)

                // Phase text
                Text(localizedPhaseText())
                    .font(.title2.bold())
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: faseIndex)

                // Breathing circle
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.purple.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 100,
                                endRadius: 180
                            )
                        )
                        .frame(width: 300, height: 300)
                        .scaleEffect(breatheScale * 1.2)

                    // Background ring
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 12)
                        .frame(width: 220, height: 220)

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: CGFloat(secondsLeft) / 240.0)
                        .stroke(
                            LinearGradient(
                                colors: [.purple, .pink, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 220, height: 220)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: secondsLeft)

                    // Inner breathing circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.5), .indigo.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(breatheScale)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.3), lineWidth: 2)
                                .scaleEffect(breatheScale)
                        )

                    // Time display
                    VStack(spacing: 4) {
                        Text(timeString(secondsLeft))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.linear, value: secondsLeft)

                        if !sessionComplete {
                            Text(String(localized: "timer_seconds"))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }

                Spacer()

                // Control button
                if sessionComplete {
                    GlassButton(String(localized: "common_done"), icon: "checkmark.circle.fill", style: .success) {
                        dismiss()
                    }
                    .padding(.horizontal, 40)
                } else {
                    GlassButton(
                        isRunning ? "Pause" : String(localized: "meditation_start"),
                        icon: isRunning ? "pause.fill" : "play.fill",
                        style: .primary
                    ) {
                        isRunning ? pausar() : iniciar()
                    }
                    .padding(.horizontal, 40)
                }

                Spacer()
                    .frame(height: 40)
            }
        }
        .onAppear {
            faseText = fases[0].text
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func localizedPhaseText() -> String {
        if sessionComplete {
            return String(localized: "meditation_complete")
        }
        return String(localized: String.LocalizationValue(fases[faseIndex].key))
    }

    private func timeString(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private func iniciar() {
        isRunning = true
        timer?.invalidate()

        // Start breathing animation
        animateBreathing()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsLeft > 0 {
                secondsLeft -= 1
                let faseActual = fases[faseIndex]
                if secondsLeft % faseActual.seconds == 0 && secondsLeft > 0 {
                    faseIndex = (faseIndex + 1) % fases.count
                    faseText = fases[faseIndex].text
                }
            } else {
                terminar()
            }
        }
    }

    private func animateBreathing() {
        let durations: [Double] = [4, 7, 8, 4]
        let scales: [CGFloat] = [1.2, 1.2, 0.8, 0.8]

        func breatheCycle() {
            guard isRunning else { return }

            for i in 0..<4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + durations[0..<i].reduce(0, +)) {
                    guard self.isRunning else { return }
                    withAnimation(.easeInOut(duration: durations[i])) {
                        breatheScale = scales[i]
                    }
                }
            }

            let totalDuration = durations.reduce(0, +)
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
                if self.isRunning {
                    breatheCycle()
                }
            }
        }

        breatheCycle()
    }

    private func pausar() {
        isRunning = false
        timer?.invalidate()
    }

    private func terminar() {
        isRunning = false
        timer?.invalidate()
        sessionComplete = true

        // Haptic feedback
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
}

#Preview {
    MeditationView()
}
