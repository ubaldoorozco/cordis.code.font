//
//  ElevatedBPMSuggestionSheet.swift
//  cordis
//

import SwiftUI

struct ElevatedBPMSuggestionSheet: View {
    let bpm: Int
    var onGuidedMeditation: () -> Void
    var onBreathingExercise: () -> Void
    var onHealthAssistant: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AnimatedGlassBackground(colorScheme: .stress)

            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 16)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.red)
                        .symbolEffect(.pulse)

                    Text("\(bpm)")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                    + Text(" BPM")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(String(localized: "suggestion_message"))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    VStack(spacing: 12) {
                        GlassButton(String(localized: "suggestion_guided_meditation"), icon: "headphones", style: .primary) {
                            onGuidedMeditation()
                            dismiss()
                        }

                        GlassButton(String(localized: "suggestion_breathing"), icon: "wind", style: .success) {
                            onBreathingExercise()
                            dismiss()
                        }

                        GlassButton(String(localized: "suggestion_assistant"), icon: "bubble.left.and.bubble.right.fill", style: .secondary) {
                            onHealthAssistant()
                            dismiss()
                        }
                    }
                    .padding(.horizontal, 24)

                    Button {
                        dismiss()
                    } label: {
                        Text(String(localized: "suggestion_dismiss"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)

                    Spacer(minLength: 16)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    Text("Preview")
        .sheet(isPresented: .constant(true)) {
            ElevatedBPMSuggestionSheet(
                bpm: 125,
                onGuidedMeditation: {},
                onBreathingExercise: {},
                onHealthAssistant: {}
            )
        }
}
