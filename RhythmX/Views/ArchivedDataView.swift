//
//  ArchivedDataView.swift
//  Rhythm
//

import SwiftUI

struct ArchivedDataView: View {
    @EnvironmentObject var archivedDataStore: ArchivedDataStore

    // For the confirmation alert to clear all
    @State private var showDeleteConfirmation = false

    // For searching tags
    @State private var searchText = ""
    
    // NEW: State for editing tags in archived events
    @State private var editingEvent: Event? = nil
    @State private var editedTags: String = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredArchivedData) { archiveBlock in
                    Section(
                        header: Text("Archived on \(archiveBlock.date.formatted(date: .abbreviated, time: .omitted))")
                    ) {
                        // Sort phases by earliest event date
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

                                    // Updated: Show each event's tags with an edit option
                                    ForEach(phase.events, id: \.id) { archivedEvent in
                                        if !archivedEvent.tags.isEmpty {
                                            HStack {
                                                Text("• \(archivedEvent.tags)")
                                                    .font(.footnote)
                                                    .foregroundColor(.blue)
                                                Spacer()
                                                Button("Edit") {
                                                    editingEvent = archivedEvent
                                                    editedTags = archivedEvent.tags
                                                }
                                                .font(.footnote)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Archived Data")
            .searchable(text: $searchText, prompt: "Search tags...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Text("Clear Archive")
                    }
                }
            }
            .alert("Delete All Archived Data?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    // Clear from the store
                    archivedDataStore.clearAllArchivedData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action will permanently remove all archived data.")
            }
        }
        // NEW: Sheet for editing an archived event's tags
        .sheet(item: $editingEvent) { event in
            NavigationStack {
                Form {
                    Section(header: Text("Edit Tags")) {
                        TextField("Tags", text: $editedTags)
                    }
                }
                .navigationTitle("Edit Tag")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            archivedDataStore.updateArchivedEventTag(eventId: event.id, newTags: editedTags)
                            editingEvent = nil
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            editingEvent = nil
                        }
                    }
                }
            }
        }
    }

    /// Filter archived data based on `searchText` in the `tags`.
    private var filteredArchivedData: [ArchivedDataBlock] {
        let allBlocks = archivedDataStore.archivedBlocks

        guard !searchText.isEmpty else {
            return allBlocks
        }

        return allBlocks.compactMap { block in
            // Filter the block's phases
            let filteredPhases = block.groupedEvents.compactMap { phase -> ArchivedDataBlock.PhaseEvents? in
                // Among this phase's events, keep only those matching the search text
                let matchingEvents = phase.events.filter {
                    $0.tags.range(of: searchText, options: .caseInsensitive) != nil
                }
                guard !matchingEvents.isEmpty else { return nil }
                return ArchivedDataBlock.PhaseEvents(
                    eventType: phase.eventType,
                    events: matchingEvents
                )
            }
            guard !filteredPhases.isEmpty else { return nil }
            
            return ArchivedDataBlock(
                id: block.id,
                date: block.date,
                groupedEvents: filteredPhases
            )
        }
    }
}

