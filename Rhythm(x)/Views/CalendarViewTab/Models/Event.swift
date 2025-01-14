//  Event.swift
//  Created by user on 9/27/24.

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

    var id: UUID = UUID() // Unique identifier for each event
    var eventType: EventType
    var date: Date
    var note: String? // Optional note property

    // Computed property to convert date to DateComponents
    var dateComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: date)
    }
}

extension Event {
    static var sampleEvents: [Event] {
        return [
            Event(eventType: .menstrual, date: Date(), note: "Menstrual phase"),
            Event(eventType: .follicular, date: Date().addingTimeInterval(86400), note: "Follicular phase"),
            Event(eventType: .ovulation, date: Date().addingTimeInterval(172800), note: "Ovulation phase"),
            Event(eventType: .luteal, date: Date().addingTimeInterval(259200), note: "Luteal phase")
        ]
    }
}

struct MenstrualCycle {
    static func calculateMenstrualPhases(startDate: String, cycleLength: Int) -> [Event] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let startDate = dateFormatter.date(from: startDate) else { return [] }

        let ovulationDay = cycleLength - 14
        guard let ovulationDate = Calendar.current.date(byAdding: .day, value: ovulationDay, to: startDate) else { return [] }
        guard let follicularEndDate = Calendar.current.date(byAdding: .day, value: -1, to: ovulationDate) else { return [] }
        let lutealStartDate = ovulationDate
        guard let lutealEndDate = Calendar.current.date(byAdding: .day, value: cycleLength - 1, to: startDate) else { return [] }

        return [
            Event(eventType: .follicular, date: startDate),
            Event(eventType: .follicular, date: follicularEndDate),
            Event(eventType: .ovulation, date: ovulationDate),
            Event(eventType: .luteal, date: lutealStartDate),
            Event(eventType: .luteal, date: lutealEndDate)
        ]
    }
}
