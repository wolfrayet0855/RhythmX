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
                // 1) Filter out introspection from the main grouping
                let nonIntrospection = myEvents.events.filter { $0.eventType != .introspection }
                
                // 2) Group those by eventType (menstrual, follicular, ovulation, luteal)
                let groupedByPhase = Dictionary(grouping: nonIntrospection) { $0.eventType }
                
                // 3) Collect all introspection events separately
                let introspectionNotes = myEvents.events.filter { $0.eventType == .introspection }
                
                // 4) For each phase (except introspection), show earliest–latest date
                ForEach(
                    Event.EventType.allCases
                        .filter { $0 != .introspection },  // exclude introspection
                    id: \.self
                ) { phase in
                    if let phaseEvents = groupedByPhase[phase], !phaseEvents.isEmpty {
                        
                        Section {
                            // Sort the phase events by date
                            let sorted = phaseEvents.sorted { $0.date < $1.date }
                            
                            // Safely get earliest + latest
                            if let firstDate = sorted.first?.date,
                               let lastDate = sorted.last?.date {
                                
                                // PHASE ROW: Name + date span
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("\(phase.icon) \(phase.rawValue.capitalized) Phase")
                                            .font(.headline)
                                        
                                        Text(
                                            "\(firstDate.formatted(date: .abbreviated, time: .omitted))"
                                            + " – "
                                            + "\(lastDate.formatted(date: .abbreviated, time: .omitted))"
                                        )
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .swipeActions {
                                    // Optionally delete all events in this phase
                                    Button(role: .destructive) {
                                        deleteAll(phaseEvents)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                                
                                // INTROSPECTION NOTES within this phase’s date range
                                let introspectionsInRange = introspectionNotes.filter {
                                    $0.date >= firstDate && $0.date <= lastDate
                                }
                                if !introspectionsInRange.isEmpty {
                                    ForEach(introspectionsInRange) { noteEvent in
                                        // A simple row for introspection note
                                        HStack {
                                            Text("Note:")
                                                .font(.callout)
                                                .fontWeight(.semibold)
                                            Text(noteEvent.note)
                                                .font(.callout)
                                        }
                                        .swipeActions {
                                            Button(role: .destructive) {
                                                myEvents.delete(noteEvent)
                                            } label: {
                                                Image(systemName: "trash")
                                            }
                                        }
                                        .onTapGesture {
                                            // If you want to edit an introspection note
                                            formType = .update(noteEvent)
                                        }
                                    }
                                }
                            }
                        } header: {
                            Text(phase.rawValue.capitalized + " Phase")
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
    
    /// Helper to delete all events in the passed array
    private func deleteAll(_ events: [Event]) {
        events.forEach { myEvents.delete($0) }
    }
}

struct EventsListView_Previews: PreviewProvider {
    static var previews: some View {
        EventsListView()
            .environmentObject(EventStore(preview: true))
    }
}
