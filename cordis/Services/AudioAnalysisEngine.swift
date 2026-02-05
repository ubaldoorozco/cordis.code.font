//
//  AudioAnalysisEngine.swift
//  cordis
//

import Foundation
import AVFoundation
import Accelerate
import Observation

@Observable
final class AudioAnalysisEngine {
    var amplitude: Float = 0.0
    var isPlaying = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0

    private var audioEngine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var audioFile: AVAudioFile?
    private var seekOffset: TimeInterval = 0
    private var fileSampleRate: Double = 44100
    private var timeUpdateTimer: Timer?

    private let smoothingFactor: Float = 0.3

    func loadAndPlay(url: URL) {
        stop()
        configureAudioSession()

        do {
            audioFile = try AVAudioFile(forReading: url)
            guard let file = audioFile else { return }

            duration = Double(file.length) / file.processingFormat.sampleRate
            fileSampleRate = file.processingFormat.sampleRate
            seekOffset = 0

            audioEngine = AVAudioEngine()
            playerNode = AVAudioPlayerNode()

            audioEngine.attach(playerNode)
            audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: file.processingFormat)

            installAmplitudeTap()

            try audioEngine.start()

            playerNode.scheduleFile(file, at: nil) { [weak self] in
                DispatchQueue.main.async {
                    self?.handlePlaybackComplete()
                }
            }
            playerNode.play()
            isPlaying = true
            startTimeUpdates()
        } catch {
            print("AudioAnalysisEngine: failed to load audio - \(error)")
        }
    }

    func pause() {
        playerNode.pause()
        isPlaying = false
        stopTimeUpdates()
    }

    func resume() {
        playerNode.play()
        isPlaying = true
        startTimeUpdates()
    }

    func stop() {
        stopTimeUpdates()
        audioEngine.mainMixerNode.removeTap(onBus: 0)
        playerNode.stop()
        audioEngine.stop()
        isPlaying = false
        amplitude = 0
        currentTime = 0
    }

    func seek(to time: TimeInterval) {
        guard let file = audioFile else { return }

        let wasPlaying = isPlaying
        playerNode.stop()

        let sampleRate = file.processingFormat.sampleRate
        let startFrame = AVAudioFramePosition(time * sampleRate)
        let totalFrames = file.length
        guard startFrame < totalFrames else { return }

        let remainingFrames = AVAudioFrameCount(totalFrames - startFrame)

        seekOffset = time
        playerNode.scheduleSegment(file, startingFrame: startFrame, frameCount: remainingFrames, at: nil) { [weak self] in
            DispatchQueue.main.async {
                self?.handlePlaybackComplete()
            }
        }

        currentTime = time

        if wasPlaying {
            playerNode.play()
            isPlaying = true
        }
    }

    private func configureAudioSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("AudioAnalysisEngine: audio session config failed - \(error)")
        }

        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: session
        )
        #endif
    }

    @objc private func handleInterruption(_ notification: Notification) {
        #if os(iOS)
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        DispatchQueue.main.async {
            if type == .began {
                self.pause()
            } else if type == .ended {
                if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume) {
                        self.resume()
                    }
                }
            }
        }
        #endif
    }

    private func installAmplitudeTap() {
        let mixerNode = audioEngine.mainMixerNode
        let format = mixerNode.outputFormat(forBus: 0)

        mixerNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            guard let self, let channelData = buffer.floatChannelData else { return }

            let frameLength = Int(buffer.frameLength)
            var rms: Float = 0

            vDSP_measqv(channelData[0], 1, &rms, vDSP_Length(frameLength))
            rms = sqrtf(rms)

            let clamped = min(max(rms, 0.0), 1.0)

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.amplitude = self.smoothingFactor * self.amplitude + (1.0 - self.smoothingFactor) * clamped
            }
        }
    }

    private func startTimeUpdates() {
        stopTimeUpdates()
        timeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.updateCurrentTime()
        }
    }

    private func stopTimeUpdates() {
        timeUpdateTimer?.invalidate()
        timeUpdateTimer = nil
    }

    private func updateCurrentTime() {
        guard isPlaying,
              let nodeTime = playerNode.lastRenderTime,
              let playerTime = playerNode.playerTime(forNodeTime: nodeTime) else { return }

        let sampleTime = Double(playerTime.sampleTime)
        let sampleRate = playerTime.sampleRate

        let playedTime = sampleTime / sampleRate
        let totalTime = seekOffset + playedTime
        if totalTime >= 0 {
            currentTime = min(totalTime, duration)
        }
    }

    private func handlePlaybackComplete() {
        isPlaying = false
        amplitude = 0
        currentTime = duration
        stopTimeUpdates()
    }

    deinit {
        timeUpdateTimer?.invalidate()
        audioEngine.mainMixerNode.removeTap(onBus: 0)
        audioEngine.stop()
        NotificationCenter.default.removeObserver(self)
    }
}
