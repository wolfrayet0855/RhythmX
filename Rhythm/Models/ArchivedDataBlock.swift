//
//  ArchivedDataBlock.swift
//

import Foundation

struct ArchivedDataBlock: Codable, Identifiable {
    let id: UUID
    let date: Date
    let groupedEvents: [PhaseEvents]

    struct PhaseEvents: Codable {
        let eventType: Event.EventType
        let events: [Event]
    }
}
