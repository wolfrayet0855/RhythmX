//  ArchivedDataView.swift
//  Rhythm
//
//  Created by user on 1/4/25.
//

import SwiftUI

struct ArchivedDataView: View {
    let groupedArchivedData: [(Date, [(Event.EventType, [Event])])]

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedArchivedData, id: \.0) { archiveDate, groupedEvents in
                    Section(header: Text("Archived on \(archiveDate.formatted(date: .abbreviated, time: .omitted))")) {
                        // Sort phases by the start date of their events
                        let sortedPhases = groupedEvents.sorted { phase1, phase2 in
                            let startDate1 = phase1.1.first?.date ?? .distantFuture
                            let startDate2 = phase2.1.first?.date ?? .distantFuture
                            return startDate1 < startDate2
                        }
                        
                        ForEach(sortedPhases, id: \.0) { phase, events in
                            if let start = events.first?.date, let end = events.last?.date {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(phase.rawValue.capitalized) Phase")
                                        .font(.headline)
                                    Text(
                                        start.formatted(date: .abbreviated, time: .omitted)
                                        + " – "
                                        + end.formatted(date: .abbreviated, time: .omitted)
                                    )
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Archived Data")
        }
    }
}

struct ArchivedDataView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleGroupedArchivedData: [(Date, [(Event.EventType, [Event])])] = [
            (
                Date(),
                [
                    (
                        .follicular,
                        [Event(eventType: .follicular, date: Date().addingTimeInterval(86400), note: "Sample Follicular Event")]
                    ),
                    (
                        .menstrual,
                        [Event(eventType: .menstrual, date: Date(), note: "Sample Menstrual Event")]
                    ),
                    (
                        .luteal,
                        [Event(eventType: .luteal, date: Date().addingTimeInterval(172800), note: "Sample Luteal Event")]
                    )
                ]
            )
        ]
        return ArchivedDataView(groupedArchivedData: sampleGroupedArchivedData)
    }
}
