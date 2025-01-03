//
//  EventStore.swift
//

import Foundation
import SwiftUI

class EventStore: ObservableObject {
    @Published var events = [Event]()
    @Published var preview: Bool
    @Published var changedEvent: Event?
    @Published var movedEvent: Event?

    @Published var lastMenstrualDate: Date?
    @Published var cycleLength: Int = 28

    init(preview: Bool = false) {
        self.preview = preview
        fetchEvents()
    }

    func fetchEvents() {
        // Load from a persistent store if you have one.
        // Otherwise, keep it empty so no initial sample data appears.
        events = []
    }

    func delete(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            changedEvent = events.remove(at: index)
        }
    }

    func add(_ event: Event) {
        events.append(event)
        changedEvent = event
    }

    func update(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            movedEvent = events[index]
            events[index] = event
            changedEvent = event
        }
    }

    /// Generates an entire new cycle. **Removes all existing events** first.
    func generateCycleEvents(startDate: Date, cycleLength: Int = 28) {
        // Completely clear out any old events.
        events.removeAll()

        // Store user input in the model.
        lastMenstrualDate = startDate
        self.cycleLength = cycleLength

        // For safety, calculate an end date (not strictly needed here).
        guard let _ = Calendar.current.date(byAdding: .day, value: cycleLength, to: startDate) else {
            return
        }

        // Example phases
        let phases: [(Event.EventType, Range<Int>)] = [
            (.menstrual, 0..<5),
            (.follicular, 5..<13),
            (.ovulation, 13..<16),
            (.luteal, 16..<27),
            (.introspection, 27..<cycleLength)
        ]

        // Create new events for each day in each phase.
        for (phaseType, dayRange) in phases {
            for offset in dayRange {
                if let phaseDate = Calendar.current.date(byAdding: .day, value: offset, to: startDate) {
                    let event = Event(
                        eventType: phaseType,
                        date: phaseDate,
                        note: "\(phaseType.rawValue.capitalized) Day \(offset + 1)"
                    )
                    add(event)
                }
            }
        }
    }
}
