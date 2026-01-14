//
//  CordisPersistence.swift
//  cordis
//
//  Extracted by assistant on 23/12/25
//

import Foundation
import SwiftData

enum CordisPersistence {
    static func makeContainer() -> ModelContainer {
        let schema = Schema([
            StressEntry.self,
            UserStats.self,
            AppSettings.self
        ])

        // Nombre estable del store
        let config = ModelConfiguration("CordisStore", schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Si el store está corrupto o migración falló, intenta borrarlo y recrear
            print("⚠️ SwiftData container load failed:", error)

            do {
                let url = try storeURL(named: "CordisStore.sqlite")
                try deleteStoreFiles(at: url)
                print("🧹 Store deleted. Retrying container creation…")

                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                print("❌ Could not delete/recreate store. Falling back to in-memory:", error)
                let mem = ModelConfiguration("CordisMemory", schema: schema, isStoredInMemoryOnly: true)
                return (try? ModelContainer(for: schema, configurations: [mem])) ?? {
                    fatalError("Unable to create any SwiftData container.")
                }()
            }
        }
    }

    private static func storeURL(named sqliteName: String) throws -> URL {
        let fm = FileManager.default
        let base = try fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        // SwiftData suele guardar aquí; usamos un nombre consistente.
        return base.appendingPathComponent(sqliteName)
    }

    private static func deleteStoreFiles(at sqliteURL: URL) throws {
        let fm = FileManager.default
        let candidates: [URL] = [
            sqliteURL,
            sqliteURL.deletingPathExtension().appendingPathExtension("sqlite-wal"),
            sqliteURL.deletingPathExtension().appendingPathExtension("sqlite-shm")
        ]
        for u in candidates where fm.fileExists(atPath: u.path) {
            try fm.removeItem(at: u)
        }
    }
}
