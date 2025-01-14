//
//  ArchivedDataBlock.swift
//

import Foundation

struct ArchivedDataBlock: Codable, Identifiable {
    let id: UUID
    let date: Date
    let groupedEvents: [PhaseEvents]

    /// Custom initializer that allows you to
    /// specify an existing id, or generate a new one.
    init(id: UUID = UUID(), date: Date, groupedEvents: [PhaseEvents]) {
        self.id = id
        self.date = date
        self.groupedEvents = groupedEvents
    }

    struct PhaseEvents: Codable {
        let eventType: Event.EventType
        let events: [Event]
    }
}
