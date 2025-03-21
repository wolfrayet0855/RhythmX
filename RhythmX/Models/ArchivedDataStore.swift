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

    /// Update the tags of a specific archived event given its ID and new tag string.
    func updateArchivedEventTag(eventId: String, newTags: String) {
        for (blockIndex, block) in archivedBlocks.enumerated() {
            var didUpdate = false
            let updatedPhases = block.groupedEvents.map { phase -> ArchivedDataBlock.PhaseEvents in
                let updatedEvents = phase.events.map { event -> Event in
                    if event.id == eventId {
                        didUpdate = true
                        var newEvent = event
                        newEvent.tags = newTags
                        return newEvent
                    }
                    return event
                }
                return ArchivedDataBlock.PhaseEvents(eventType: phase.eventType, events: updatedEvents)
            }
            if didUpdate {
                let updatedBlock = ArchivedDataBlock(id: block.id, date: block.date, groupedEvents: updatedPhases)
                archivedBlocks[blockIndex] = updatedBlock
                saveArchivedData()
                break
            }
        }
    }
}
