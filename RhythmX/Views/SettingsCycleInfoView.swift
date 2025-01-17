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

    // MARK: - Archived Data
    @State private var groupedArchivedData: [ArchivedDataBlock] = []
    private let archivedDataKey = "com.example.rhythm(x).archivedData"

    // MARK: - Lifecycle
    init() {
        loadArchivedData()
    }

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
                        // 1) Generate
                        eventStore.generateCycleEvents(
                            startDate: selectedStartDate,
                            cycleLength: selectedCycleLength
                        )
                        // 2) Show alert
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
                    footer: Text("Archiving will save the existing events. New events will need to be regenerated.")
                ) {
                    Button {
                        archiveCurrentData()
                    } label: {
                        Text("Archive Current Data")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    NavigationLink("View Archived Data") {
                        ArchivedDataView(
                            groupedArchivedData: $groupedArchivedData
                        ) {
                            // Clear all blocks from memory + from disk
                            groupedArchivedData.removeAll()
                            saveArchivedData()
                        }
                    }
                }
            }
            .navigationTitle("Settings")

            // MARK: - ALERTS
            .alert("Cycle Events Generated", isPresented: $showCycleGeneratedAlert) {
                Button("OK") {
                    // Immediately reload to show new icons
                    eventStore.reloadCalendarIcons()
                }
            }

            .alert("Data Archived Successfully", isPresented: $showArchivedAlert) {
                Button("OK") {
                    // Immediately reload to remove icons
                    eventStore.reloadCalendarIcons()
                }
            }
        }
    }

    // MARK: - Archiving
    private func archiveCurrentData() {
        // If there are no events, do nothing
        guard !eventStore.events.isEmpty else { return }

        // 1) Gather existing events
        let currentEvents = eventStore.events

        // 2) Convert them into archived block(s)
        let grouped = Dictionary(grouping: currentEvents) { $0.eventType }
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .map { (key, events) in
                ArchivedDataBlock.PhaseEvents(eventType: key, events: events)
            }

        let newBlock = ArchivedDataBlock(
            id: UUID(),
            date: Date(),
            groupedEvents: grouped
        )

        // 3) Append to local archive list + sort (newest first)
        groupedArchivedData.append(newBlock)
        groupedArchivedData.sort { $0.date > $1.date }

        // 4) Clear the current events from EventStore
        eventStore.clearAllEvents()

        // 5) Save the updated archive list
        saveArchivedData()

        // 6) Alert the user
        showArchivedAlert = true
    }

    // MARK: - Persistence for Archives
    private func loadArchivedData() {
        guard let data = UserDefaults.standard.data(forKey: archivedDataKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([ArchivedDataBlock].self, from: data)
            groupedArchivedData = decoded
        } catch {
            print("Error decoding archived data: \(error)")
        }
    }

    private func saveArchivedData() {
        do {
            let data = try JSONEncoder().encode(groupedArchivedData)
            UserDefaults.standard.set(data, forKey: archivedDataKey)
        } catch {
            print("Error encoding archived data: \(error)")
        }
    }
}
