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

    var body: some View {
        NavigationStack {
            List {
                // Show each ArchivedDataBlock in descending order if you wish
                // (or ascending, if that’s your preference)
                ForEach(filteredArchivedData) { archiveBlock in
                    Section(
                        header: Text("Archived on \(archiveBlock.date.formatted(date: .abbreviated, time: .omitted))")
                    ) {
                        // Sort the phases by earliest event date
                        let sortedPhases = archiveBlock.groupedEvents.sorted { p1, p2 in
                            let start1 = p1.events.first?.date ?? .distantFuture
                            let start2 = p2.events.first?.date ?? .distantFuture
                            return start1 < start2
                        }

                        ForEach(sortedPhases, id: \.eventType.id) { phase in
                            // If the phase has at least one event, show it
                            if let firstDate = phase.events.first?.date,
                               let lastDate = phase.events.last?.date {
                                VStack(alignment: .leading, spacing: 6) {
                                    // Title
                                    Text("\(phase.eventType.rawValue.capitalized) Phase")
                                        .font(.headline)
                                    // Date range
                                    Text(
                                        firstDate.formatted(date: .abbreviated, time: .omitted)
                                        + " – "
                                        + lastDate.formatted(date: .abbreviated, time: .omitted)
                                    )
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                    // Show bullet points of each event’s tags
                                    ForEach(phase.events, id: \.id) { e in
                                        if !e.tags.isEmpty {
                                            Text("• \(e.tags)")
                                                .font(.footnote)
                                                .foregroundColor(.blue)
                                        }
                                    }

                                    // NavigationLink to push a new view for editing
                                    NavigationLink("Edit All Tags") {
                                        PhaseTagsEditorView(phase: phase)
                                    }
                                    .font(.footnote)
                                    .padding(.top, 4)
                                }
                                .padding(.vertical, 4)
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
                    archivedDataStore.clearAllArchivedData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action will permanently remove all archived data.")
            }
        }
    }

    /// Filter archived data based on `searchText` in the `tags`.
    private var filteredArchivedData: [ArchivedDataBlock] {
        let allBlocks = archivedDataStore.archivedBlocks
        guard !searchText.isEmpty else { return allBlocks }

        // Return only blocks that contain phases with events matching the search text
        return allBlocks.compactMap { block in
            let filteredPhases = block.groupedEvents.compactMap { phase -> ArchivedDataBlock.PhaseEvents? in
                let matchingEvents = phase.events.filter {
                    $0.tags.range(of: searchText, options: .caseInsensitive) != nil
                }
                guard !matchingEvents.isEmpty else { return nil }
                return ArchivedDataBlock.PhaseEvents(eventType: phase.eventType, events: matchingEvents)
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

