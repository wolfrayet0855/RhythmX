//  EventsListView.swift

import SwiftUI

struct EventsListView: View {
    @EnvironmentObject var myEvents: EventStore
    @State private var showTagForm = false
    @State private var editingPhase: Event.EventType? = nil

    var body: some View {
        NavigationStack {
            Group {
                if myEvents.events.isEmpty {
                    emptyState
                } else {
                    eventList
                }
            }
            .navigationTitle("Tag Management")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Add New Tag") {
                            showTagForm = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.medium)
                    }
                }
            }
            .sheet(isPresented: $showTagForm) {
                TagFormView()
            }
            .sheet(item: $editingPhase) { phase in
                PhaseTagEditorSheet(phase: phase)
            }
        }
    }

    private var eventList: some View {
        List {
            let grouped = Dictionary(grouping: myEvents.events) { $0.eventType }

            ForEach(Event.EventType.allCases, id: \.self) { phase in
                if let phaseEvents = grouped[phase], !phaseEvents.isEmpty {
                    let sorted = phaseEvents.sorted { $0.date < $1.date }
                    Section {
                        if !sorted.isEmpty {
                            HStack {
                                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                                    let combinedTags = sorted
                                        .map { $0.tags }
                                        .filter { !$0.isEmpty }
                                        .joined(separator: ", ")
                                    if !combinedTags.isEmpty {
                                        Text("Tags: \(combinedTags)")
                                            .font(DS.Font.caption)
                                            .foregroundColor(.accentColor)
                                    } else {
                                        Text("No tags yet - tap + to add")
                                            .font(DS.Font.caption)
                                            .foregroundColor(DS.Color.secondaryText)
                                    }
                                }
                                Spacer()
                                Button {
                                    editingPhase = phase
                                } label: {
                                    Image(systemName: "pencil.circle")
                                        .foregroundColor(.accentColor)
                                        .imageScale(.large)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    } header: {
                        if let earliest = sorted.first, let latest = sorted.last {
                            PhaseCardHeader(
                                phase: phase,
                                startDate: earliest.date,
                                endDate: latest.date
                            )
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        VStack(spacing: DS.Spacing.md) {
            Spacer()
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(DS.Color.secondaryText)
            Text("No Events Yet")
                .font(DS.Font.sectionHeader)
                .foregroundColor(DS.Color.primaryText)
            Text("Go to Manage to generate your first cycle.")
                .font(DS.Font.label)
                .foregroundColor(DS.Color.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Spacing.xl)
            Spacer()
        }
    }


}

// MARK: - Phase Tag Editor Sheet
private struct PhaseTagEditorSheet: View {
    let phase: Event.EventType
    @EnvironmentObject var myEvents: EventStore
    @Environment(\.dismiss) var dismiss

    @State private var editingTags: [String: String] = [:]

    private var phaseEvents: [Event] {
        myEvents.events.filter { $0.eventType == phase }.sorted { $0.date < $1.date }
    }

    private func tagBinding(for event: Event) -> Binding<String> {
        Binding(
            get: { editingTags[event.id] ?? event.tags },
            set: { editingTags[event.id] = $0 }
        )
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Category:Value, comma-separated - e.g. Symptom:Cramps")
                        .font(DS.Font.micro)
                        .foregroundColor(DS.Color.secondaryText)
                        .listRowBackground(Color.clear)
                }

                ForEach(phaseEvents) { event in
                    Section {
                        TextField("Tags", text: tagBinding(for: event), axis: .vertical)
                            .lineLimit(2...4)
                            .font(DS.Font.caption)
                            .foregroundColor(DS.Color.primaryText)
                    } header: {
                        Text(event.date.formatted(date: .abbreviated, time: .omitted))
                            .font(DS.Font.micro)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Edit \(phase.displayName) Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        for event in phaseEvents {
                            if let newTags = editingTags[event.id] {
                                var updated = event
                                updated.tags = newTags
                                myEvents.update(updated)
                            }
                        }
                        dismiss()
                    }
                    .font(DS.Font.label.weight(.semibold))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    EventsListView()
        .environmentObject(EventStore(preview: true))
}
