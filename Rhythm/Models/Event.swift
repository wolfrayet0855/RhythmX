//
//  Event.swift
//  Created by user on 9/27/24.
//

import Foundation

struct Event: Identifiable, Codable {
    enum EventType: String, Identifiable, CaseIterable, Codable {
        case menstrual
        case follicular
        case ovulation
        case luteal
        case introspection  // optional extra case if needed

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .menstrual:     return "❶"
            case .follicular:    return "❷"
            case .ovulation:     return "❸"
            case .luteal:        return "❹"
            case .introspection: return "☪︎"
            }
        }
    }

    /// Unique string ID for each event
    var id: String

    var eventType: EventType
    var date: Date

    /// Optional note describing the event
    var note: String

    /// Freeform text for custom tags
    var tags: String

    /// Computed property to convert the event's date to DateComponents
    var dateComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: date)
    }

    // MARK: - Initializer
    init(
        id: String = UUID().uuidString,
        eventType: EventType,
        date: Date,
        note: String,
        tags: String = ""
    ) {
        self.id = id
        self.eventType = eventType
        self.date = date
        self.note = note
        self.tags = tags
    }
}

// MARK: - Sample Events & MenstrualCycle helper
extension Event {
    static var sampleEvents: [Event] {
        return [
            Event(eventType: .menstrual,     date: Date(),                     note: "Menstrual phase",     tags: ""),
            Event(eventType: .follicular,    date: Date().addingTimeInterval(86400),   note: "Follicular phase",    tags: ""),
            Event(eventType: .ovulation,     date: Date().addingTimeInterval(172800),  note: "Ovulation phase",     tags: ""),
            Event(eventType: .luteal,        date: Date().addingTimeInterval(259200),  note: "Luteal phase",        tags: ""),
            Event(eventType: .introspection, date: Date().addingTimeInterval(345600),  note: "Introspection phase", tags: "")
        ]
    }
}

struct MenstrualCycle {
    static func calculateMenstrualPhases(startDate: String, cycleLength: Int) -> [Event] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let start = dateFormatter.date(from: startDate) else { return [] }

        let ovulationDay = cycleLength - 14
        guard let ovulationDate = Calendar.current.date(byAdding: .day, value: ovulationDay, to: start) else { return [] }
        guard let follicularEndDate = Calendar.current.date(byAdding: .day, value: -1, to: ovulationDate) else { return [] }
        let lutealStartDate = ovulationDate
        guard let lutealEndDate = Calendar.current.date(byAdding: .day, value: cycleLength - 1, to: start) else { return [] }

        return [
            Event(eventType: .follicular, date: start,           note: "Follicular start"),
            Event(eventType: .follicular, date: follicularEndDate, note: "Follicular end"),
            Event(eventType: .ovulation,  date: ovulationDate,   note: "Ovulation"),
            Event(eventType: .luteal,     date: lutealStartDate, note: "Luteal start"),
            Event(eventType: .luteal,     date: lutealEndDate,   note: "Luteal end")
        ]
    }
}

