//
//  ArchivedDataView.swift
//  Rhythm
//
//  Created by user on 1/4/25.
//

import SwiftUI

struct ArchivedDataView: View {
    let groupedArchivedData: [ArchivedDataBlock]

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedArchivedData) { archiveBlock in
                    Section(header: Text("Archived on \(archiveBlock.date.formatted(date: .abbreviated, time: .omitted))")) {
                        // Sort phases by the start date of their events
                        let sortedPhases = archiveBlock.groupedEvents.sorted { phase1, phase2 in
                            let startDate1 = phase1.events.first?.date ?? .distantFuture
                            let startDate2 = phase2.events.first?.date ?? .distantFuture
                            return startDate1 < startDate2
                        }

                        ForEach(sortedPhases, id: \.eventType.id) { phase in
                            if let firstDate = phase.events.first?.date,
                               let lastDate = phase.events.last?.date {

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(phase.eventType.rawValue.capitalized) Phase")
                                        .font(.headline)
                                    Text(
                                        firstDate.formatted(date: .abbreviated, time: .omitted)
                                        + " – "
                                        + lastDate.formatted(date: .abbreviated, time: .omitted)
                                    )
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                    // If you want to show tags for these archived events:
                                    ForEach(phase.events, id: \.id) { archivedEvent in
                                        if !archivedEvent.tags.isEmpty {
                                            Text("• Tags: \(archivedEvent.tags)")
                                                .font(.footnote)
                                                .foregroundColor(.blue)
                                        }
                                    }
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
