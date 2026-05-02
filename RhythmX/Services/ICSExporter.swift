//  ICSExporter.swift

import Foundation

struct ICSExporter {
    static func export(events: [Event], sharerName: String) -> Data {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = TimeZone.current

        var lines = [
            "BEGIN:VCALENDAR",
            "VERSION:2.0",
            "PRODID:-//RhythmX//RhythmX//EN",
            "CALSCALE:GREGORIAN",
            "METHOD:PUBLISH"
        ]

        for phase in Event.EventType.allCases {
            let dates = events
                .filter { $0.eventType == phase }
                .map { Calendar.current.startOfDay(for: $0.date) }
            guard let startDate = dates.min(), let lastDate = dates.max() else { continue }
            guard let endDate = Calendar.current.date(byAdding: .day, value: 1, to: lastDate) else { continue }
            let trimmedName = sharerName.trimmingCharacters(in: .whitespaces)
            let rawSummary = trimmedName.isEmpty
                ? phase.displayName
                : "\(trimmedName)'s \(phase.displayName)"
            let summary = ICSExporter.escapeText(rawSummary)

            lines += [
                "BEGIN:VEVENT",
                "UID:rhythmx-\(phase.rawValue)",
                "DTSTART;VALUE=DATE:\(formatter.string(from: startDate))",
                "DTEND;VALUE=DATE:\(formatter.string(from: endDate))",
                "SUMMARY:\(summary)",
                "END:VEVENT"
            ]
        }

        lines.append("END:VCALENDAR")
        return (lines.joined(separator: "\r\n") + "\r\n").data(using: .utf8)!
    }

    private static func escapeText(_ string: String) -> String {
        string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: ";",  with: "\\;")
            .replacingOccurrences(of: ",",  with: "\\,")
    }
}
