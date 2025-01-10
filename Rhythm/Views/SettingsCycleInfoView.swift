//
//  SettingsCycleInfoView.swift
//

import SwiftUI

struct SettingsCycleInfoView: View {
    @EnvironmentObject var eventStore: EventStore

    @State private var selectedStartDate: Date = Date()
    @State private var selectedCycleLength: Int = 28
    @State private var showCycleGeneratedAlert = false
    @State private var showArchivedAlert = false
    @State private var groupedArchivedData: [(Date, [(Event.EventType, [Event])])] = []

    var body: some View {
        NavigationStack {
            Form {
                // -- User Note Section with a standard header
                Section(header: Text("System Note")) {
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            // First line: "Add new tags"
                            HStack {
                                Text("Add new tags in")
                                    .foregroundColor(.black)
                                Image(systemName: "list.bullet")
                                    .foregroundColor(.black)
                                Text("list view")
                            }
                            // Second line: "Edit tags"
                            HStack {
                                Text("Edit tags in")
                                    .foregroundColor(.black)
                                Image(systemName: "calendar")
                                    .foregroundColor(.black)
                                Text("calendar view")
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }

                // Menstrual Phases Info Section
                Section(header: Text("Menstrual Phases Info")) {
                    NavigationLink("Learn more about phases") {
                        PhasesFactsView()
                    }
                }

                // Cycle Information Section
                Section(header: Text("Cycle Information")) {
                    DatePicker(
                        "First Day of Current Cycle",
                        selection: $selectedStartDate,
                        displayedComponents: .date
                    )
                    Stepper(value: $selectedCycleLength, in: 20...40) {
                        Text("Cycle Length: \(selectedCycleLength) days")
                    }
                }

                // Generate Cycle Events Section
                Section(
                    header: Text("Generate Events"),
                    footer: Text("This clears existing events and regenerates new dates for the upcoming cycle.")
                ) {
                    Button(action: {
                        DispatchQueue.main.async {
                            eventStore.generateCycleEvents(
                                startDate: selectedStartDate,
                                cycleLength: selectedCycleLength
                            )
                            showCycleGeneratedAlert = true
                        }
                    }) {
                        Text("Generate Cycle Events")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }

                // Archive Section
                Section(
                    header: Text("Archive Data"),
                    footer: Text("Archiving will save the existing events. New events will need to be regenerated.")
                ) {
                    Button(action: {
                        archiveCurrentData()
                    }) {
                        Text("Archive Current Data")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    NavigationLink("View Archived Data") {
                        ArchivedDataView(groupedArchivedData: groupedArchivedData)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Cycle Events Generated", isPresented: $showCycleGeneratedAlert) {
                Button("OK", role: .cancel) {}
            }
            .alert("Data Archived Successfully", isPresented: $showArchivedAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    // Archive the current data and group it incrementally
    private func archiveCurrentData() {
        let currentEvents = eventStore.events
        guard !currentEvents.isEmpty else { return }

        // Group events by phase
        let groupedEvents = Dictionary(grouping: currentEvents) { $0.eventType }
            .sorted { $0.key.rawValue < $1.key.rawValue }

        // Add the grouped events to archived data with the current date
        groupedArchivedData.append((Date(), groupedEvents))

        // Sort archives by date (most recent first)
        groupedArchivedData.sort { $0.0 > $1.0 }

        // Clear current events (optional, depending on business logic)
        eventStore.events.removeAll()

        // Show success alert
        showArchivedAlert = true
    }
}

struct SettingsCycleInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCycleInfoView()
            .environmentObject(EventStore(preview: true))
    }
}

