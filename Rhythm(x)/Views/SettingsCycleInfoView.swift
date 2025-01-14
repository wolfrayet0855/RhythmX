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
                    Button {
                        DispatchQueue.main.async {
                            eventStore.generateCycleEvents(
                                startDate: selectedStartDate,
                                cycleLength: selectedCycleLength
                            )
                            showCycleGeneratedAlert = true
                        }
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
                        // Pass a binding + a closure to clear the archive
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
            .alert("Cycle Events Generated", isPresented: $showCycleGeneratedAlert) {
                Button("OK", role: .cancel) {}
            }
            .alert("Data Archived Successfully", isPresented: $showArchivedAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    // MARK: - Archiving
    private func archiveCurrentData() {
        let currentEvents = eventStore.events
        guard !currentEvents.isEmpty else { return }

        // Group events by phase
        let grouped = Dictionary(grouping: currentEvents) { $0.eventType }
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .map { (key, events) in
                ArchivedDataBlock.PhaseEvents(eventType: key, events: events)
            }

        // Build a new ArchivedDataBlock (auto-generates id)
        let newBlock = ArchivedDataBlock(
            date: Date(),
            groupedEvents: grouped
        )

        // Append & sort newest at the top
        groupedArchivedData.append(newBlock)
        groupedArchivedData.sort { $0.date > $1.date }

        // Clear current events (optional)
        eventStore.events.removeAll()

        // Persist archived data
        saveArchivedData()

        // Show success alert
        showArchivedAlert = true
    }

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
