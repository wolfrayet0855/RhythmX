//
//  ArchivedDataStore.swift
//  RhythmX
//
//  Created by user on 1/31/25.
//
import Foundation

@MainActor
class ArchivedDataStore: ObservableObject {
    @Published var archivedBlocks: [ArchivedDataBlock] = []

    // Adjust your UserDefaults key, if needed
    private let archivedDataKey = "com.example.rhythm(x).archivedData"

    init() {
        loadArchivedData()
    }

    func loadArchivedData() {
        guard let data = UserDefaults.standard.data(forKey: archivedDataKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([ArchivedDataBlock].self, from: data)
            self.archivedBlocks = decoded
        } catch {
            print("Error decoding archived data: \(error)")
        }
    }

    func saveArchivedData() {
        do {
            let data = try JSONEncoder().encode(archivedBlocks)
            UserDefaults.standard.set(data, forKey: archivedDataKey)
        } catch {
            print("Error encoding archived data: \(error)")
        }
    }

    /// Append a new Archive block, then save.
    func appendArchivedBlock(_ newBlock: ArchivedDataBlock) {
        archivedBlocks.append(newBlock)
        // Sort newest first if you like:
        archivedBlocks.sort { $0.date > $1.date }
        saveArchivedData()
    }

    /// Clear all archived data, then save.
    func clearAllArchivedData() {
        archivedBlocks.removeAll()
        saveArchivedData()
    }
}
