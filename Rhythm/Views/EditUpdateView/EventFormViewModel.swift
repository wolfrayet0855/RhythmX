//
//  EventFormViewModel.swift
//

import Foundation

class EventFormViewModel: ObservableObject {
    @Published var date = Date()
    @Published var note = ""
    @Published var eventType: Event.EventType = .menstrual
    @Published var tags = ""
    
    var id: String?
    var updating: Bool { id != nil }
    
    init() {}

    init(_ event: Event) {
        date = event.date
        note = event.note
        eventType = event.eventType
        tags = event.tags
        id = event.id
    }

    var incomplete: Bool {
        note.isEmpty
    }
}
