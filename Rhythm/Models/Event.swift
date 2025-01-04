//
//  Event.swift
//

import Foundation

/// Main model for an event, now with 4 phases + freeform tags.
struct Event: Identifiable {
    enum EventType: String, Identifiable, CaseIterable {
        case menstrual, follicular, ovulation, luteal

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .menstrual:  return "❶"
            case .follicular: return "❷"
            case .ovulation:  return "❸"
            case .luteal:     return "❹"
            }
        }
    }

    var eventType: EventType
    var date: Date
    var note: String
    var tags: String      // Comma-separated or freeform text for custom tags
    var id: String

    var dateComponents: DateComponents {
        var comps = Calendar.current.dateComponents(
            [.month, .day, .year, .hour, .minute],
            from: date
        )
        comps.timeZone = TimeZone.current
        comps.calendar = Calendar(identifier: .gregorian)
        return comps
    }

    init(
        id: String = UUID().uuidString,
        eventType: EventType,
        date: Date,
        note: String,
        tags: String = ""
    ) {
        self.eventType = eventType
        self.date = date
        self.note = note
        self.tags = tags
        self.id = id
    }
}
