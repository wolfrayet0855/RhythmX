//
//  EventStore.swift
//

import Foundation

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

    /// In a real app, load from disk or a database. For now, keep empty or test data.
    func fetchEvents() {
        if preview {
            // For a quick preview, you could add sample data. We'll keep empty here:
            events = []
        } else {
            events = []
        }
    }

    func delete(_ event: Event) {
        if let idx = events.firstIndex(where: { $0.id == event.id }) {
            changedEvent = events.remove(at: idx)
        }
    }

    func add(_ newEvent: Event) {
        events.append(newEvent)
        changedEvent = newEvent
    }

    func update(_ event: Event) {
        if let idx = events.firstIndex(where: { $0.id == event.id }) {
            movedEvent = events[idx]
            events[idx] = event
            changedEvent = event
        }
    }
    
    /// Example function to generate a cycle of events for demonstration
    func generateCycleEvents(startDate: Date, cycleLength: Int = 28) {
        // Clear existing events to illustrate new cycle
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
                        note: "\(phaseType.rawValue.capitalized) day \(offset+1)",
                        tags: ""
                    )
                    add(e)
                }
            }
        }
    }
}

