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

    // MARK: - Cycle Info
    @Published var lastMenstrualDate: Date?
    @Published var cycleLength: Int = 28

    init(preview: Bool = false) {
        self.preview = preview
        fetchEvents()
    }

    func fetchEvents() {
        if preview {
            // Show sample data in preview mode
            events = Event.sampleEvents
        } else {
            // For now, also load sample events in non-preview
            // so the list isn't blank at startup.
            events = Event.sampleEvents
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
    /// This now only removes existing events in the new cycle's date range
    /// to avoid duplication. Tweak date ranges as needed for your real logic.
    func generateCycleEvents(startDate: Date, cycleLength: Int = 28) {
        // Store the user inputs in the model
        lastMenstrualDate = startDate
        self.cycleLength = cycleLength

        // End date is startDate + cycleLength
        guard let endDate = Calendar.current.date(
            byAdding: .day,
            value: cycleLength,
            to: startDate
        ) else { return }

        // Remove existing events that fall within [startDate, endDate)
        events.removeAll { event in
            (event.date >= startDate) && (event.date < endDate)
        }

        // Example phases
        let phases: [(Event.EventType, Range<Int>)] = [
            (.menstrual, 0..<5),      // Day 1-5
            (.follicular, 5..<13),    // Day 6-13
            (.ovulation, 13..<16),    // Day 14-16
            (.luteal, 16..<27),       // Day 17-27
            (.introspection, 27..<cycleLength)  // Day 28-(cycleLength)
        ]

        // Build events for each day in each phase
        for (phaseType, dayRange) in phases {
            for offset in dayRange {
                guard let phaseDate = Calendar.current.date(
                    byAdding: .day,
                    value: offset,
                    to: startDate
                ) else { continue }

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
