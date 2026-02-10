//
//  ManualMeasurementView.swift
//  cordis
//
//  Created for CORDIS App
//

import SwiftUI

struct ManualMeasurementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var beatsCount: Int = 0
    @State private var calculatedBPM: Int = 0
    @State private var showResult = false

    var onSave: (Int) -> Void

    var body: some View {
        ZStack {
            AnimatedGlassBackground(colorScheme: .calm)

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        if currentStep > 0 {
                            withAnimation {
                                currentStep -= 1
                            }
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: currentStep > 0 ? "chevron.left" : "xmark")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }

                    Spacer()

                    // Step indicator
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { step in
                            Capsule()
                                .fill(step <= currentStep ? Color.white : Color.white.opacity(0.3))
                                .frame(width: step == currentStep ? 24 : 8, height: 8)
                                .animation(.spring(duration: 0.3), value: currentStep)
                        }
                    }

                    Spacer()

                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding()

                Spacer()

                // Content based on step
                Group {
                    switch currentStep {
                    case 0:
                        tutorialStep
                    case 1:
                        timerStep
                    case 2:
                        inputStep
                    default:
                        EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                Spacer()
            }
            .frame(maxWidth: 700)
        }
        .sheet(isPresented: $showResult) {
            resultSheet
        }
    }

    // MARK: - Step 1: Tutorial

    private var tutorialStep: some View {
        VStack(spacing: 30) {
            Text(String(localized: "manual_tutorial_title"))
                .font(.title.bold())
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            WristGuideView()
                .padding(.vertical)

            VStack(alignment: .leading, spacing: 16) {
                instructionRow(number: 1, text: String(localized: "manual_step_1"))
                instructionRow(number: 2, text: String(localized: "manual_step_2"))
                instructionRow(number: 3, text: String(localized: "manual_step_3"))
                instructionRow(number: 4, text: String(localized: "manual_step_4"))
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)

            GlassButton(String(localized: "manual_ready"), icon: "play.fill") {
                withAnimation {
                    currentStep = 1
                }
            }
            .padding(.horizontal)
        }
    }

    private func instructionRow(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Color.purple)
                .clipShape(Circle())

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.9))
        }
    }

    // MARK: - Step 2: Timer

    private var timerStep: some View {
        VStack(spacing: 30) {
            Text(String(localized: "manual_timer_title"))
                .font(.title.bold())
                .foregroundStyle(.primary)

            CountdownTimerView(totalSeconds: 15) {
                withAnimation {
                    currentStep = 2
                }
            }
            .padding()
        }
    }

    // MARK: - Step 3: Input

    private var inputStep: some View {
        VStack(spacing: 30) {
            Text(String(localized: "manual_input_title"))
                .font(.title.bold())
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Text(String(localized: "manual_input_subtitle"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            // Beat counter
            GlassCard {
                VStack(spacing: 20) {
                    Text(String(localized: "manual_beats_counted"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 30) {
                        Button {
                            if beatsCount > 0 {
                                beatsCount -= 1
                                updateBPM()
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(.purple)
                        }

                        Text("\(beatsCount)")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .frame(minWidth: 100)
                            .contentTransition(.numericText())
                            .animation(.spring(duration: 0.2), value: beatsCount)

                        Button {
                            beatsCount += 1
                            updateBPM()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(.purple)
                        }
                    }

                    // Quick buttons
                    HStack(spacing: 12) {
                        ForEach([10, 15, 20, 25], id: \.self) { count in
                            Button {
                                beatsCount = count
                                updateBPM()
                            } label: {
                                Text("\(count)")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(beatsCount == count ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(beatsCount == count ? Color.purple : Color.gray.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)

            // Calculated BPM
            if beatsCount > 0 {
                GlassCardAccent(accentColor: .green) {
                    VStack(spacing: 8) {
                        Text(String(localized: "manual_calculated_bpm"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(calculatedBPM)")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .contentTransition(.numericText())
                                .animation(.spring(duration: 0.2), value: calculatedBPM)

                            Text("BPM")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }

                        Text(String(localized: "manual_formula"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .transition(.scale.combined(with: .opacity))
            }

            if calculatedBPM > 0 {
                GlassButton(String(localized: "manual_save"), icon: "checkmark.circle.fill", style: .success) {
                    showResult = true
                }
                .padding(.horizontal)
            }
        }
        .animation(.spring(duration: 0.3), value: beatsCount > 0)
    }

    // MARK: - Result Sheet

    private var resultSheet: some View {
        NavigationStack {
            ZStack {
                AnimatedGlassBackground(colorScheme: stressColorScheme)

                VStack(spacing: 30) {
                    // Success icon
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.green)

                    Text(String(localized: "manual_result_saved"))
                        .font(.title.bold())
                        .foregroundStyle(.primary)

                    // BPM Display
                    GlassCard {
                        VStack(spacing: 12) {
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text("\(calculatedBPM)")
                                    .font(.system(size: 56, weight: .bold, design: .rounded))
                                Text("BPM")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }

                            Text(stressLevelText)
                                .font(.headline)
                                .foregroundStyle(stressColor)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)

                    Spacer()

                    GlassButton(String(localized: "manual_done"), icon: "checkmark") {
                        onSave(calculatedBPM)
                        showResult = false
                        dismiss()
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .padding(.top, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showResult = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Helpers

    private func updateBPM() {
        calculatedBPM = beatsCount * 4
    }

    private var stressLevelText: String {
        // Simplified - would use age group in real implementation
        if calculatedBPM < 60 { return String(localized: "stress_low") }
        if calculatedBPM < 80 { return String(localized: "stress_excellent") }
        if calculatedBPM < 100 { return String(localized: "stress_normal") }
        if calculatedBPM < 120 { return String(localized: "stress_elevated") }
        return String(localized: "stress_high")
    }

    private var stressColor: Color {
        if calculatedBPM < 60 { return .purple }
        if calculatedBPM < 80 { return .green }
        if calculatedBPM < 100 { return .blue }
        if calculatedBPM < 120 { return .orange }
        return .red
    }

    private var stressColorScheme: AnimatedGlassBackground.BackgroundColorScheme {
        if calculatedBPM < 80 { return .success }
        if calculatedBPM < 100 { return .calm }
        return .stress
    }
}

// MARK: - Preview

#Preview {
    ManualMeasurementView { bpm in
        print("Saved BPM: \(bpm)")
    }
}
