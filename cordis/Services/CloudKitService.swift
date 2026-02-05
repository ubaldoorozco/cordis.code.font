//
//  CloudKitService.swift
//  cordis
//

import Foundation
import CloudKit
import Observation

struct GuidedMeditationItem: Identifiable {
    let id: CKRecord.ID
    let title: String
    let duration: Int
    let description: String
    let sortOrder: Int
    let recordChangeTag: String?
    var localAudioURL: URL?
}

@Observable
final class CloudKitService {
    var meditations: [GuidedMeditationItem] = []
    var isLoading = false
    var errorMessage: String?

    private let container = CKContainer(identifier: "iCloud.cordis")
    private let recordType = "GuidedMeditation"

    private var cachesDirectory: URL {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = caches.appendingPathComponent("GuidedMeditations", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func fetchMeditations() async {
        isLoading = true
        errorMessage = nil

        let query = CKQuery(recordType: recordType, predicate: NSPredicate(format: "sortOrder >= %d", 0))
        query.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]

        do {
            let (results, _) = try await container.publicCloudDatabase.records(matching: query)
            var items: [GuidedMeditationItem] = []

            for (_, result) in results {
                guard let record = try? result.get() else { continue }
                let title = record["title"] as? String ?? ""
                let duration = record["duration"] as? Int ?? 0
                let description = record["thumbnailDescription"] as? String ?? ""
                let sortOrder = record["sortOrder"] as? Int ?? 0

                let localURL = localAudioURL(for: record.recordID.recordName)
                let fileExists = FileManager.default.fileExists(atPath: localURL.path)

                items.append(GuidedMeditationItem(
                    id: record.recordID,
                    title: title,
                    duration: duration,
                    description: description,
                    sortOrder: sortOrder,
                    recordChangeTag: record.recordChangeTag,
                    localAudioURL: fileExists ? localURL : nil
                ))
            }

            meditations = items.sorted { $0.sortOrder < $1.sortOrder }
        } catch {
            print("❌ CloudKit fetch error: \(error)")
            if meditations.isEmpty {
                loadCachedMeditations()
            }
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func downloadAudio(for item: GuidedMeditationItem) async -> URL? {
        let savedTag = UserDefaults.standard.string(forKey: "ck_tag_\(item.id.recordName)")
        let localURL = localAudioURL(for: item.id.recordName)

        if let tag = item.recordChangeTag,
           tag == savedTag,
           FileManager.default.fileExists(atPath: localURL.path) {
            return localURL
        }

        do {
            let record = try await container.publicCloudDatabase.record(for: item.id)
            guard let asset = record["audioFile"] as? CKAsset,
                  let fileURL = asset.fileURL else { return nil }

            try? FileManager.default.removeItem(at: localURL)
            try FileManager.default.copyItem(at: fileURL, to: localURL)

            if let tag = record.recordChangeTag {
                UserDefaults.standard.set(tag, forKey: "ck_tag_\(item.id.recordName)")
            }

            if let index = meditations.firstIndex(where: { $0.id == item.id }) {
                meditations[index].localAudioURL = localURL
            }

            return localURL
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private func localAudioURL(for recordName: String) -> URL {
        cachesDirectory.appendingPathComponent("\(recordName).m4a")
    }

    private func loadCachedMeditations() {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(at: cachesDirectory, includingPropertiesForKeys: nil) else { return }

        var cached: [GuidedMeditationItem] = []
        for file in files where file.pathExtension == "m4a" {
            let name = file.deletingPathExtension().lastPathComponent
            cached.append(GuidedMeditationItem(
                id: CKRecord.ID(recordName: name),
                title: name,
                duration: 0,
                description: "",
                sortOrder: cached.count,
                recordChangeTag: nil,
                localAudioURL: file
            ))
        }

        if !cached.isEmpty {
            meditations = cached
        }
    }
}
