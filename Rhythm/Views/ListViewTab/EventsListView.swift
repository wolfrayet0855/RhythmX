//
//  EventsListView.swift
//
import SwiftUI

struct EventsListView: View {
    @EnvironmentObject var myEvents: EventStore
    @State private var formType: EventFormType?

    var body: some View {
        NavigationStack {
            List {
                // Group events by eventType (the 4 phases)
                let grouped = Dictionary(grouping: myEvents.events) { $0.eventType }

                // We iterate over each known phase in order:
                ForEach(Event.EventType.allCases, id: \.self) { phase in
                    if let phaseEvents = grouped[phase], !phaseEvents.isEmpty {
                        Section {
                            // Sort by date
                            let sorted = phaseEvents.sorted { $0.date < $1.date }
                            if let earliest = sorted.first, let latest = sorted.last {
                                // Show single row for the phase date range
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("\(phase.icon) \(phase.rawValue.capitalized) Phase")
                                            .font(.headline)
                                        Text(
                                            earliest.date.formatted(date: .abbreviated, time: .omitted)
                                            + " – "
                                            + latest.date.formatted(date: .abbreviated, time: .omitted)
                                        )
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .swipeActions {
                                    // Delete all events in this phase, if desired
                                    Button(role: .destructive) {
                                        deleteAll(phaseEvents)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }

                                // Optionally show each event in that phase if you want more details:
                                // ForEach(sorted) { e in
                                //     ListViewRow(event: e, formType: $formType)
                                //         .swipeActions {
                                //             Button(role: .destructive) {
                                //                 myEvents.delete(e)
                                //             } label: {
                                //                 Image(systemName: "trash")
                                //             }
                                //         }
                                // }
                            }
                        } header: {
                            Text("\(phase.rawValue.capitalized) Phase")
                        }
                    }
                }
            }
            .navigationTitle("Calendar Events")
            .sheet(item: $formType) { $0 }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        formType = .new
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.medium)
                    }
                }
            }
        }
    }

    private func deleteAll(_ events: [Event]) {
        for e in events {
            myEvents.delete(e)
        }
    }
}

struct EventsListView_Previews: PreviewProvider {
    static var previews: some View {
        EventsListView()
            .environmentObject(EventStore(preview: true))
    }
}
