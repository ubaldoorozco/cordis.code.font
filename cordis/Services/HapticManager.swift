//
//  HapticManager.swift
//  cordis
//

import Foundation
import CoreHaptics

final class HapticManager {
    var isEnabled = true

    private(set) var isSupported: Bool
    private var engine: CHHapticEngine?
    private var player: CHHapticAdvancedPatternPlayer?

    init() {
        isSupported = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    func start() {
        guard isSupported, isEnabled else { return }

        do {
            let engine = try CHHapticEngine()
            self.engine = engine

            engine.resetHandler = { [weak self] in
                do {
                    try self?.engine?.start()
                } catch {
                    print("HapticManager: reset restart failed - \(error)")
                }
            }

            engine.stoppedHandler = { reason in
                print("HapticManager: engine stopped - \(reason.rawValue)")
            }

            try engine.start()

            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [intensity, sharpness],
                relativeTime: 0,
                duration: 100
            )

            let pattern = try CHHapticPattern(events: [event], parameters: [])
            player = try engine.makeAdvancedPlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("HapticManager: start failed - \(error)")
        }
    }

    func updateAmplitude(_ amplitude: Float) {
        guard isSupported, isEnabled, let player else { return }

        let intensity = 0.3 + amplitude * 0.7
        let sharpness = 0.1 + amplitude * 0.6

        do {
            let intensityParam = CHHapticDynamicParameter(
                parameterID: .hapticIntensityControl,
                value: intensity,
                relativeTime: 0
            )
            let sharpnessParam = CHHapticDynamicParameter(
                parameterID: .hapticSharpnessControl,
                value: sharpness,
                relativeTime: 0
            )
            try player.sendParameters([intensityParam, sharpnessParam], atTime: CHHapticTimeImmediate)
        } catch {
            print("HapticManager: update failed - \(error)")
        }
    }

    func stop() {
        do {
            try player?.stop(atTime: CHHapticTimeImmediate)
        } catch {
            print("HapticManager: stop player failed - \(error)")
        }
        player = nil
        engine?.stop()
        engine = nil
    }
}
