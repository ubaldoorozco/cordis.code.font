//
//  GuidedMeditationPlayerView.swift
//  cordis
//

import SwiftUI

struct GuidedMeditationPlayerView: View {
    let item: GuidedMeditationItem
    var cloudKit: CloudKitService
    @State private var audioEngine = AudioAnalysisEngine()
    @State private var hapticManager = HapticManager()
    @State private var isDownloading = false
    @State private var downloadError: String?
    @State private var isSeeking = false
    @State private var seekFraction: Double = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 32) {
                Spacer()

                titleSection

                pulsingCircle

                timeDisplay

                progressBar

                controlsRow

                Spacer()
            }
            .padding(.horizontal, 30)
            .frame(maxWidth: 700)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .task {
            await prepareAudio()
        }
        .onChange(of: audioEngine.amplitude) { _, newValue in
            hapticManager.updateAmplitude(newValue)
        }
        .onDisappear {
            audioEngine.stop()
            hapticManager.stop()
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        let amp = CGFloat(audioEngine.amplitude)
        return ZStack {
            AnimatedGlassBackground(colorScheme: .calm)
            Color.purple.opacity(amp * 0.2)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: audioEngine.amplitude)
        }
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(spacing: 8) {
            Text(item.localizedTitle)
                .font(.title.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            if !item.localizedDescription.isEmpty {
                Text(item.localizedDescription)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Pulsing Circle

    private var pulsingCircle: some View {
        let amp = CGFloat(audioEngine.amplitude)
        let scale = 1.0 + amp * 0.3
        let s: CGFloat = sizeClass == .regular ? 1.4 : 1.0

        return ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.purple.opacity(0.3 + amp * 0.15), .clear],
                        center: .center,
                        startRadius: 80 * s,
                        endRadius: 160 * s
                    )
                )
                .frame(width: 260 * s, height: 260 * s)
                .scaleEffect(scale * 1.15)

            // Main circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            .purple.opacity(0.5 + amp * 0.3),
                            .indigo.opacity(0.3 + amp * 0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200 * s, height: 200 * s)
                .scaleEffect(scale)

            // Inner ring
            Circle()
                .stroke(.white.opacity(0.3), lineWidth: 2)
                .frame(width: 200 * s, height: 200 * s)
                .scaleEffect(scale)

            // Icon
            if isDownloading {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            } else {
                Image(systemName: audioEngine.isPlaying ? "waveform" : "headphones")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .symbolEffect(.variableColor.iterative, isActive: audioEngine.isPlaying)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: audioEngine.amplitude)
    }

    // MARK: - Time

    private var displayTime: TimeInterval {
        isSeeking ? seekFraction * audioEngine.duration : audioEngine.currentTime
    }

    private var timeDisplay: some View {
        HStack {
            Text(formatTime(displayTime))
                .monospacedDigit()
            Spacer()
            Text("-\(formatTime(max(0, audioEngine.duration - displayTime)))")
                .monospacedDigit()
        }
        .font(.subheadline)
        .foregroundColor(.white.opacity(0.6))
    }

    // MARK: - Progress

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.2))
                    .frame(height: 6)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: progressWidth(in: geo.size.width), height: 6)
            }
            .frame(height: 30)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isSeeking = true
                        seekFraction = max(0, min(1, value.location.x / geo.size.width))
                    }
                    .onEnded { value in
                        let fraction = max(0, min(1, value.location.x / geo.size.width))
                        let seekTime = Double(fraction) * audioEngine.duration
                        audioEngine.seek(to: seekTime)
                        isSeeking = false
                    }
            )
        }
        .frame(height: 30)
    }

    private func progressWidth(in totalWidth: CGFloat) -> CGFloat {
        guard audioEngine.duration > 0 else { return 0 }
        let fraction = isSeeking ? seekFraction : audioEngine.currentTime / audioEngine.duration
        return CGFloat(fraction) * totalWidth
    }

    // MARK: - Controls

    private var controlsRow: some View {
        HStack(spacing: 40) {
            // Haptics toggle
            Button {
                hapticManager.isEnabled.toggle()
                if hapticManager.isEnabled && audioEngine.isPlaying {
                    hapticManager.start()
                } else if !hapticManager.isEnabled {
                    hapticManager.stop()
                }
            } label: {
                Image(systemName: hapticManager.isEnabled ? "hand.point.up.braille.fill" : "hand.point.up.braille")
                    .font(.title2)
                    .foregroundColor(hapticManager.isEnabled ? .purple : .white.opacity(0.4))
            }

            // Play/Pause
            Button {
                togglePlayback()
            } label: {
                Image(systemName: audioEngine.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .disabled(isDownloading || (item.localAudioURL == nil && downloadError != nil))

            // Skip back 15s
            Button {
                let target = max(0, audioEngine.currentTime - 15)
                audioEngine.seek(to: target)
            } label: {
                Image(systemName: "gobackward.15")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }

    // MARK: - Actions

    private func prepareAudio() async {
        if let url = item.localAudioURL, FileManager.default.fileExists(atPath: url.path) {
            return
        }

        isDownloading = true
        downloadError = nil

        if await cloudKit.downloadAudio(for: item) != nil {
            isDownloading = false
        } else {
            isDownloading = false
            downloadError = String(localized: "meditation_download_error")
        }
    }

    private func togglePlayback() {
        if audioEngine.isPlaying {
            audioEngine.pause()
            hapticManager.stop()
        } else {
            if audioEngine.currentTime >= audioEngine.duration && audioEngine.duration > 0 {
                if let url = currentAudioURL {
                    audioEngine.loadAndPlay(url: url)
                    if hapticManager.isEnabled { hapticManager.start() }
                }
            } else if audioEngine.duration > 0 {
                audioEngine.resume()
                if hapticManager.isEnabled { hapticManager.start() }
            } else if let url = currentAudioURL {
                audioEngine.loadAndPlay(url: url)
                if hapticManager.isEnabled { hapticManager.start() }
            }
        }
    }

    private var currentAudioURL: URL? {
        if let updated = cloudKit.meditations.first(where: { $0.id == item.id }),
           let url = updated.localAudioURL,
           FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        if let url = item.localAudioURL, FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        return nil
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
