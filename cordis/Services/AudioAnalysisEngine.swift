//
//  AudioAnalysisEngine.swift
//  cordis
//

import Foundation
import AVFoundation
import Observation

@Observable
final class AudioAnalysisEngine: NSObject, AVAudioPlayerDelegate {
    var amplitude: Float = 0.0
    var isPlaying = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0

    private var player: AVAudioPlayer?
    private var timeUpdateTimer: Timer?

    private let smoothingFactor: Float = 0.3

    func loadAndPlay(url: URL) {
        stop()
        configureAudioSession()

        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.isMeteringEnabled = true
            newPlayer.delegate = self
            newPlayer.prepareToPlay()

            duration = newPlayer.duration
            player = newPlayer
            newPlayer.play()
            isPlaying = true
            startTimeUpdates()
        } catch {
            print("AudioAnalysisEngine: failed to load audio - \(error)")
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
        stopTimeUpdates()
    }

    func resume() {
        player?.play()
        isPlaying = true
        startTimeUpdates()
    }

    func stop() {
        stopTimeUpdates()
        player?.stop()
        player = nil
        isPlaying = false
        amplitude = 0
        currentTime = 0
    }

    func seek(to time: TimeInterval) {
        guard let player else { return }
        let clamped = max(0, min(time, duration))
        player.currentTime = clamped
        currentTime = clamped
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.handlePlaybackComplete()
        }
    }

    // MARK: - Audio Session

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

    // MARK: - Time Updates

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
        guard isPlaying, let player else { return }

        currentTime = player.currentTime

        player.updateMeters()
        let dB = player.averagePower(forChannel: 0)
        let linear = pow(10.0, dB / 20.0)
        let clamped = min(max(linear, 0.0), 1.0)
        amplitude = smoothingFactor * amplitude + (1.0 - smoothingFactor) * clamped
    }

    private func handlePlaybackComplete() {
        isPlaying = false
        amplitude = 0
        currentTime = duration
        stopTimeUpdates()
    }

    deinit {
        timeUpdateTimer?.invalidate()
        player?.stop()
        NotificationCenter.default.removeObserver(self)
    }
}
