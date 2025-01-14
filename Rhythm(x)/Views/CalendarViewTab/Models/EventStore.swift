//  EventStore.swift
//  Created by user on 9/27/24.

import Foundation

class EventStore: ObservableObject {
    @Published var events: [Event] = [] // Array to hold events

    // Function to add a new event
    func add(event: Event) {
        events.append(event)
    }

    // Function to delete an event
    func delete(_ event: Event) {
        events.removeAll { $0.id == event.id }
    }

    // Function to load sample events
    func loadSampleEvents() {
        events = Event.sampleEvents
    }
}
