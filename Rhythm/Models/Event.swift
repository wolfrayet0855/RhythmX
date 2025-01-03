//
//  Event.swift
//

import Foundation

struct Event: Identifiable {
    enum EventType: String, Identifiable, CaseIterable {
        case menstrual, follicular, ovulation, luteal, introspection

        var id: String {
            self.rawValue
        }

        var icon: String {
            switch self {
            case .menstrual:
                return "❶"
            case .follicular:
                return "❷"
            case .ovulation:
                return "❸"
            case .luteal:
                return "❹"
            case .introspection:
                return "☪︎"
            }
        }
    }

    var eventType: EventType
    var date: Date
    var note: String
    var id: String

    var dateComponents: DateComponents {
        var dateComponents = Calendar.current.dateComponents(
            [.month, .day, .year, .hour, .minute],
            from: date
        )
        dateComponents.timeZone = TimeZone.current
        dateComponents.calendar = Calendar(identifier: .gregorian)
        return dateComponents
    }

    init(
        id: String = UUID().uuidString,
        eventType: EventType = .introspection,
        date: Date,
        note: String
    ) {
        self.eventType = eventType
        self.date = date
        self.note = note
        self.id = id
    }
}
