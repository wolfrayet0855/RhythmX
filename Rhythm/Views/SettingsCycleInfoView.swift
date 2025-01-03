//
//  SettingsCycleInfoView.swift
//
import SwiftUI

struct SettingsCycleInfoView: View {
    @EnvironmentObject var eventStore: EventStore

    @State private var selectedStartDate: Date = Date()
    @State private var selectedCycleLength: Int = 28
    @State private var showCycleGeneratedAlert = false

    var body: some View {
        NavigationStack {
            Form {
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

                Section {
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
                } footer: {
                    Text("This clears existing events and regenerates new dates for the upcoming cycle.")
                }

                // NEW SECTION: Navigate to phases info
                Section(header: Text("Menstrual Phases Info")) {
                    NavigationLink("Learn more about phases") {
                        PhasesFactsView()
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Cycle Events Generated", isPresented: $showCycleGeneratedAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}

struct SettingsCycleInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCycleInfoView()
            .environmentObject(EventStore(preview: true))
    }
}
