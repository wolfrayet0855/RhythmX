//
//  SettingsCycleInfoView.swift
//

import SwiftUI

struct SettingsCycleInfoView: View {
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var archivedDataStore: ArchivedDataStore

    @State private var selectedStartDate: Date = Date()
    @State private var selectedCycleLength: Int = 28

    @State private var showCycleGeneratedAlert = false
    @State private var showArchivedAlert = false
    @State private var showArchivePrompt = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Getting Started")) {
                    NavigationLink("Let’s Get Started") {
                        GettingStartedView()
                    }
                }

                Section(header: Text("Menstrual Phases Info")) {
                    NavigationLink("Learn more about phases") {
                        PhasesFactsView()
                    }
                }

                Section(header: Text("Cycle Information")) {
                    DatePicker("First Day of Current Cycle", selection: $selectedStartDate, displayedComponents: .date)
                    Stepper(value: $selectedCycleLength, in: 20...40) {
                        Text("Cycle Length: \(selectedCycleLength) days")
                    }
                }

                Section(
                    header: Text("Generate Events"),
                    footer: Text("Clears current events (with archive option) and generates new ones for the upcoming cycle.")
                ) {
                    Button {
                        if eventStore.events.isEmpty {
                            generateEventsAndAlert()
                        } else {
                            showArchivePrompt = true
                        }
                    } label: {
                        Text("Generate Cycle Events")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section(header: Text("Archive & Insights")) {
                    NavigationLink("View Archived Data") {
                        ArchivedDataView()
                    }

                    NavigationLink("Visualization") {
                        ArchivedDataSymptomVisualizationView()
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Cycle Events Generated", isPresented: $showCycleGeneratedAlert) {
                Button("OK") {
                    eventStore.reloadCalendarIcons()
                }
            }
            .alert("Data Archived Successfully", isPresented: $showArchivedAlert) {
                Button("OK") {
                    eventStore.reloadCalendarIcons()
                }
            }
            .alert("Archive your current data?", isPresented: $showArchivePrompt) {
                Button("Yes") {
                    archiveCurrentData()
                    generateEventsAndAlert()
                }
                Button("No", role: .cancel) {
                    generateEventsAndAlert()
                }
            } message: {
                Text("Would you like to archive your existing events before generating a new cycle?")
            }
        }
    }

    private func archiveCurrentData() {
        guard !eventStore.events.isEmpty else { return }

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

        archivedDataStore.appendArchivedBlock(newBlock)
        eventStore.clearAllEvents()
        showArchivedAlert = true
    }

    private func generateEventsAndAlert() {
        eventStore.generateCycleEvents(
            startDate: selectedStartDate,
            cycleLength: selectedCycleLength
        )
        showCycleGeneratedAlert = true
    }
}

