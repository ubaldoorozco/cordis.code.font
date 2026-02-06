//
//  CordisPersistence.swift
//  cordis
//
// ubaldo orozco  on 23/12/25
//

import Foundation
import SwiftData

enum CordisPersistence {
    static func makeContainer() -> ModelContainer {
        let schema = Schema([
            StressEntry.self,
            UserStats.self,
            AppSettings.self,
            ChatMessage.self
        ])

        // Nombre estable del store
        let config = ModelConfiguration("CordisStore", schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Si el store está corrupto o migración falló, intenta borrarlo y recrear
            print("⚠️ SwiftData container load failed:", error)

            do {
                let url = try storeURL(named: "CordisStore")
                try deleteStoreFiles(at: url)
                print("🧹 Store deleted. Retrying container creation…")

                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                print("❌ Could not delete/recreate store. Falling back to in-memory:", error)
                let mem = ModelConfiguration("CordisMemory", schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
                return (try? ModelContainer(for: schema, configurations: [mem])) ?? {
                    fatalError("Unable to create any SwiftData container.")
                }()
            }
        }
    }

    private static func storeURL(named storeName: String) throws -> URL {
        let fm = FileManager.default
        let base = try fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        // SwiftData uses .store extension
        return base.appendingPathComponent(storeName + ".store")
    }

    private static func deleteStoreFiles(at storeURL: URL) throws {
        let fm = FileManager.default
        let baseName = storeURL.deletingPathExtension()

        // SwiftData can create multiple files with different extensions
        let candidates: [URL] = [
            storeURL,
            baseName.appendingPathExtension("store-wal"),
            baseName.appendingPathExtension("store-shm"),
            // Also try sqlite extensions for legacy support
            baseName.appendingPathExtension("sqlite"),
            baseName.appendingPathExtension("sqlite-wal"),
            baseName.appendingPathExtension("sqlite-shm")
        ]
        for u in candidates where fm.fileExists(atPath: u.path) {
            try fm.removeItem(at: u)
        }
    }
}
