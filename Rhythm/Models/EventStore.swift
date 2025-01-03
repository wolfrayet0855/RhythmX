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

    @Published var lastMenstrualDate: Date?
    @Published var cycleLength: Int = 28

    init(preview: Bool = false) {
        self.preview = preview
        fetchEvents()
    }

    func fetchEvents() {
        // In a real app, load from your persistent store or simply set events to [].
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
            events[index].date = event.date
            events[index].note = event.note
            events[index].eventType = event.eventType
            changedEvent = event
        }
    }

    func generateCycleEvents(startDate: Date, cycleLength: Int = 28) {
        lastMenstrualDate = startDate
        self.cycleLength = cycleLength
        guard let endDate = Calendar.current.date(byAdding: .day, value: cycleLength, to: startDate) else { return }

        events.removeAll { event in
            (event.date >= startDate) && (event.date < endDate)
        }

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
                    note: "\(phaseType.rawValue.capitalized) Day \(offset + 1)"
                )
                add(event)
            }
        }
    }
}
