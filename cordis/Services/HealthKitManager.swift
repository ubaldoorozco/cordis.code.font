//
//  HealthKitManager.swift
//  cordis
//
//  Created for CORDIS App
//

import Foundation
import HealthKit
import Combine

@MainActor
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKObserverQuery?

    @Published var isAvailable: Bool = false
    @Published var isAuthorized: Bool = false
    @Published var latestHeartRate: Double?
    @Published var lastReadingDate: Date?
    @Published var errorMessage: String?

    private init() {
        checkAvailability()
    }

    // MARK: - Availability Check

    func checkAvailability() {
        isAvailable = HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        guard isAvailable else {
            errorMessage = String(localized: "healthkit_not_available")
            return false
        }

        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            errorMessage = String(localized: "healthkit_heart_rate_unavailable")
            return false
        }

        let typesToRead: Set<HKObjectType> = [heartRateType]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)

            // Check if we actually got authorization
            let status = healthStore.authorizationStatus(for: heartRateType)
            isAuthorized = status == .sharingAuthorized || status != .notDetermined

            if isAuthorized {
                await fetchLatestHeartRate()
                startObservingHeartRate()
            }

            return isAuthorized
        } catch {
            errorMessage = error.localizedDescription
            isAuthorized = false
            return false
        }
    }

    // MARK: - Fetch Latest Heart Rate

    func fetchLatestHeartRate() async {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] _, samples, error in
            Task { @MainActor in
                guard let self = self else { return }

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let sample = samples?.first as? HKQuantitySample else {
                    return
                }

                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let heartRate = sample.quantity.doubleValue(for: heartRateUnit)

                self.latestHeartRate = heartRate
                self.lastReadingDate = sample.endDate
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Real-time Observation

    func startObservingHeartRate() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        // Stop any existing query
        if let existingQuery = heartRateQuery {
            healthStore.stop(existingQuery)
        }

        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] _, completionHandler, error in
            if error != nil {
                completionHandler()
                return
            }

            Task { @MainActor in
                await self?.fetchLatestHeartRate()
            }

            completionHandler()
        }

        heartRateQuery = query
        healthStore.execute(query)
    }

    func stopObservingHeartRate() {
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
    }

    // MARK: - Get Heart Rate for Time Range

    func getHeartRateStatistics(from startDate: Date, to endDate: Date) async -> (average: Double?, min: Double?, max: Double?) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return (nil, nil, nil)
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: heartRateType,
                quantitySamplePredicate: predicate,
                options: [.discreteAverage, .discreteMin, .discreteMax]
            ) { _, statistics, _ in
                let avg = statistics?.averageQuantity()?.doubleValue(for: heartRateUnit)
                let min = statistics?.minimumQuantity()?.doubleValue(for: heartRateUnit)
                let max = statistics?.maximumQuantity()?.doubleValue(for: heartRateUnit)

                continuation.resume(returning: (avg, min, max))
            }

            self.healthStore.execute(query)
        }
    }

    // MARK: - Format Heart Rate

    func formattedHeartRate(_ bpm: Double?) -> String {
        guard let bpm = bpm else {
            return "--"
        }
        return String(format: "%.0f", bpm)
    }

    func formattedLastReadingTime() -> String? {
        guard let date = lastReadingDate else {
            return nil
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
