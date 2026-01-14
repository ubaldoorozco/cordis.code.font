//
//  MeditationView.swift
//  cordis
//
//  Extracted by assistant on 23/12/25
//

import SwiftUI

struct MeditationView: View {
    @State private var secondsLeft = 4 * 60
    @State private var faseText = "Inhala"
    @State private var isRunning = false
    @State private var timer: Timer?

    let fases: [(text: String, seconds: Int)] = [
        ("Inhala", 4),
        ("Mantén", 7),
        ("Exhala", 8),
        ("Respira normal", 4)
    ]
    @State private var faseIndex = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 40) {
                Text("Meditación guiada")
                    .font(.largeTitle).bold()
                    .foregroundColor(.orange)

                Text(faseText)
                    .font(.title).bold()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 20)
                        .frame(width: 250, height: 250)

                    Circle()
                        .trim(from: 0, to: CGFloat(secondsLeft) / 240.0)
                        .stroke(.orange, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(-90))

                    Text("\(secondsLeft)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.white)
                        .monospacedDigit()
                }

                Button(isRunning ? "Pausar" : "Iniciar") {
                    isRunning ? pausar() : iniciar()
                }
                .font(.title2.bold())
                .padding(20)
                .frame(width: 200)
                .background(.orange)
                .foregroundColor(.white)
                .cornerRadius(15)
            }
        }
        .onDisappear { timer?.invalidate() }
    }

    private func iniciar() {
        isRunning = true
        timer?.invalidate()
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

    private func pausar() {
        isRunning = false
        timer?.invalidate()
    }

    private func terminar() {
        isRunning = false
        timer?.invalidate()
        faseText = "Meditación finalizada"
    }
}
