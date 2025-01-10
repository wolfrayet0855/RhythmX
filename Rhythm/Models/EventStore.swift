//
//  EventStore.swift
//

import Foundation
import SwiftUI

@MainActor
class EventStore: ObservableObject {
    @Published var events = [Event]()
    @Published var preview: Bool
    @Published var changedEvent: Event?
    @Published var movedEvent: Event?

    init(preview: Bool = false) {
        self.preview = preview
        fetchEvents()
    }

    /// Example "fetch" that sets events to empty if in preview
    func fetchEvents() {
        if preview {
            events = []
        } else {
            events = []
        }
    }

    // MARK: - CRUD
    func add(_ newEvent: Event) {
        events.append(newEvent)
        changedEvent = newEvent
    }

    func delete(_ event: Event) {
        if let idx = events.firstIndex(where: { $0.id == event.id }) {
            changedEvent = events.remove(at: idx)
        }
    }

    func update(_ event: Event) {
        if let idx = events.firstIndex(where: { $0.id == event.id }) {
            movedEvent = events[idx]
            events[idx] = event
            changedEvent = event
        }
    }

    // MARK: - Generate cycle events
    func generateCycleEvents(startDate: Date, cycleLength: Int = 28) {
        events.removeAll()
        let phases: [(Event.EventType, Range<Int>)] = [
            (.menstrual,   0..<5),
            (.follicular,  5..<13),
            (.ovulation,   13..<16),
            (.luteal,      16..<cycleLength)
        ]

        for (phaseType, dayRange) in phases {
            for offset in dayRange {
                if let phaseDate = Calendar.current.date(byAdding: .day, value: offset, to: startDate) {
                    let e = Event(
                        eventType: phaseType,
                        date: phaseDate,
                        note: "\(phaseType.rawValue.capitalized) day \(offset+1)"
                    )
                    add(e)
                }
            }
        }
    }

    // Optional: fetch historical events
    func fetchHistoricalEvents(for range: TimeInterval) -> [Event] {
        let startDate = Date().addingTimeInterval(-range)
        return events.filter { $0.date >= startDate }
    }
}

