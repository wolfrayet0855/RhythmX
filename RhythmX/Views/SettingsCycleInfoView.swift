//
//  SettingsCycleInfoView.swift
//
import SwiftUI

struct SettingsCycleInfoView: View {
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var archivedDataStore: ArchivedDataStore

    // Existing state for cycle generation
    @State private var selectedStartDate: Date = Date()
    @State private var selectedCycleLength: Int = 28

    @State private var showCycleGeneratedAlert = false
    @State private var showArchivedAlert = false

    var body: some View {
        NavigationStack {
            Form {
                // -- "Getting Started" Section
                Section(header: Text("Getting Started")) {
                    NavigationLink("Let’s Get Started") {
                        GettingStartedView()
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
                    DatePicker("First Day of Current Cycle", selection: $selectedStartDate, displayedComponents: .date)

                    Stepper(value: $selectedCycleLength, in: 20...40) {
                        Text("Cycle Length: \(selectedCycleLength) days")
                    }
                }

                // Generate Cycle Events Section
                Section(
                    header: Text("Generate Events"),
                    footer: Text("This clears existing events and regenerates new dates for the upcoming cycle.")
                ) {
                    Button {
                        // 1) Generate new events
                        eventStore.generateCycleEvents(
                            startDate: selectedStartDate,
                            cycleLength: selectedCycleLength
                        )
                        // 2) Show alert to confirm
                        showCycleGeneratedAlert = true
                    } label: {
                        Text("Generate Cycle Events")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }

                // Archive Section
                Section(
                    header: Text("Archive Data"),
                    footer: Text("Archiving will save the existing events. Then you can generate new events.")
                ) {
                    Button {
                        archiveCurrentData()
                    } label: {
                        Text("Archive Current Data")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    NavigationLink("View Archived Data") {
                        ArchivedDataView()
                    }
                    
                    NavigationLink("Visualization") {
                        ArchivedDataSymptomVisualizationView()
                    }
                }
            }
            .navigationTitle("Settings")
            // MARK: - ALERTS
            .alert("Cycle Events Generated", isPresented: $showCycleGeneratedAlert) {
                Button("OK") {
                    // Force calendar reload
                    eventStore.reloadCalendarIcons()
                }
            }
            .alert("Data Archived Successfully", isPresented: $showArchivedAlert) {
                Button("OK") {
                    // Force calendar reload
                    eventStore.reloadCalendarIcons()
                }
            }
        }
    }

    // MARK: - Archive Current Data
    private func archiveCurrentData() {
        guard !eventStore.events.isEmpty else { return }

        // 1) Group events
        let groupedPhases = Dictionary(grouping: eventStore.events) { $0.eventType }
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .map { (key, events) in
                ArchivedDataBlock.PhaseEvents(eventType: key, events: events)
            }

        let newBlock = ArchivedDataBlock(
            id: UUID(),
            date: Date(),
            groupedEvents: groupedPhases
        )

        // 2) Append to archived store
        archivedDataStore.appendArchivedBlock(newBlock)

        // 3) Clear current events
        eventStore.clearAllEvents()

        // 4) Alert
        showArchivedAlert = true
    }
}
