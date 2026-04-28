//  EventsListView.swift

import SwiftUI

struct EventsListView: View {
    @EnvironmentObject var myEvents: EventStore
    @State private var showTagForm = false

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
                    Button {
                        showTagForm.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.medium)
                    }
                }
            }
            .sheet(isPresented: $showTagForm) {
                TagFormView()
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
                                    }
                                }
                                Spacer()
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    deleteAll(phaseEvents)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .accessibilityLabel("Delete")
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

    private func deleteAll(_ events: [Event]) {
        for e in events {
            myEvents.delete(e)
        }
    }
}

#Preview {
    EventsListView()
        .environmentObject(EventStore(preview: true))
}
