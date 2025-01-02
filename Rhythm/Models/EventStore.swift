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

    // MARK: - Cycle Info (could be persisted in real app)
    @Published var lastMenstrualDate: Date?
    @Published var cycleLength: Int = 28

    init(preview: Bool = false) {
        self.preview = preview
        fetchEvents()
    }

    func fetchEvents() {
        if preview {
            events = Event.sampleEvents
        } else {
            // Load from your persistent store if needed
            events = []
        }
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
            events[index].date = event.date
            events[index].note = event.note
            events[index].eventType = event.eventType
            changedEvent = event
        }
    }

    /// Generates a simple cycle of phase events for the user.
    /// Adjust the day ranges or logic to match your ideal lengths per phase.
    func generateCycleEvents(startDate: Date, cycleLength: Int = 28) {
        // For simplicity, remove existing events in this demonstration.
        // In a real app, you might want to handle merges or confirmations.
        events.removeAll()

        // Store the lastMenstrualDate and cycleLength
        lastMenstrualDate = startDate
        self.cycleLength = cycleLength

        // Example phases (days are inclusive):
        //  Menstrual: Day 0...4
        //  Follicular: Day 5...12
        //  Ovulation: Day 13...15
        //  Luteal: Day 16...26
        //  Introspection: Day 27...(cycleLength-1)

        let phases: [(Event.EventType, Range<Int>)] = [
            (.menstrual, 0..<5),
            (.follicular, 5..<13),
            (.ovulation, 13..<16),
            (.luteal, 16..<27),
            (.introspection, 27..<cycleLength)
        ]

        for (phaseType, dayRange) in phases {
            for offset in dayRange {
                guard let phaseDate = Calendar.current.date(byAdding: .day, value: offset, to: startDate) else { continue }
                let event = Event(
                    eventType: phaseType,
                    date: phaseDate,
                    note: "\(phaseType.rawValue.capitalized) Day \(offset+1)"
                )
                add(event)
            }
        }
    }
}
