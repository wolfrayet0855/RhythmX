//
//  ArchivedDataView.swift
//  Rhythm
//

import SwiftUI

struct ArchivedDataView: View {
    // A binding so we can mutate the parent's array
    @Binding var groupedArchivedData: [ArchivedDataBlock]

    // A callback that clears + saves in the parent
    let clearArchivedData: () -> Void

    // For the confirmation alert
    @State private var showDeleteConfirmation = false

    // For searching tags
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                // We iterate over filteredArchivedData
                ForEach(filteredArchivedData) { archiveBlock in
                    Section(header: Text("Archived on \(archiveBlock.date.formatted(date: .abbreviated, time: .omitted))")) {
                        // Sort phases by earliest event date
                        let sortedPhases = archiveBlock.groupedEvents.sorted { phase1, phase2 in
                            let startDate1 = phase1.events.first?.date ?? .distantFuture
                            let startDate2 = phase2.events.first?.date ?? .distantFuture
                            return startDate1 < startDate2
                        }

                        ForEach(sortedPhases, id: \.eventType.id) { phase in
                            if let firstDate = phase.events.first?.date,
                               let lastDate = phase.events.last?.date
                            {
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

                                    // Show each event's tags (already filtered by search)
                                    ForEach(phase.events, id: \.id) { archivedEvent in
                                        if !archivedEvent.tags.isEmpty {
                                            Text("• \(archivedEvent.tags)")
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
            // Add a search bar
            .searchable(text: $searchText, prompt: "Search tags...")
            // Toolbar button for clearing data
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Text("Clear Archive")
                    }
                }
            }
            // Confirmation .alert for deletion
            .alert("Delete All Archived Data?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    clearArchivedData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action will permanently remove all archived data.")
            }
        }
    }

    /// Filter archived data based on `searchText` in the `tags`
    private var filteredArchivedData: [ArchivedDataBlock] {
        // If user hasn't entered anything, show all
        guard !searchText.isEmpty else {
            return groupedArchivedData
        }

        // Otherwise, filter
        return groupedArchivedData.compactMap { block in
            // Filter the block's phases
            let filteredPhases = block.groupedEvents.compactMap { phase -> ArchivedDataBlock.PhaseEvents? in
                // Among this phase's events, keep only those matching the search text
                let matchingEvents = phase.events.filter {
                    $0.tags.range(of: searchText, options: .caseInsensitive) != nil
                }
                // If no matches, skip this phase
                guard !matchingEvents.isEmpty else {
                    return nil
                }
                // Otherwise build the new filtered PhaseEvents
                return ArchivedDataBlock.PhaseEvents(eventType: phase.eventType, events: matchingEvents)
            }

            // If after filtering, no phases remain, skip this entire block
            guard !filteredPhases.isEmpty else {
                return nil
            }

            // Otherwise, build a new block with only the matching phases
            return ArchivedDataBlock(
                id: block.id,          // preserve original ID
                date: block.date,
                groupedEvents: filteredPhases
            )
        }
    }
}

