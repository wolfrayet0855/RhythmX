//
//  SettingsCycleInfoView.swift
//
import SwiftUI

struct SettingsCycleInfoView: View {
    @EnvironmentObject var eventStore: EventStore

    @State private var selectedStartDate: Date = Date()
    @State private var selectedCycleLength: Int = 28

    // Used to trigger the pop-up
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
                        // Defer the actual operation to avoid publishing changes
                        DispatchQueue.main.async {
                            // Clear out old events + create fresh ones
                            eventStore.generateCycleEvents(
                                startDate: selectedStartDate,
                                cycleLength: selectedCycleLength
                            )
                            // Show the alert
                            showCycleGeneratedAlert = true
                        }
                    }) {
                        Text("Generate Cycle Events")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                footer: {
                    Text("This removes any previously added events and regenerates new dates for the upcoming cycle.")
                }
            }
            .navigationTitle("Settings")
            // Show an alert after generating
            .alert(
                "Cycle Events Generated",
                isPresented: $showCycleGeneratedAlert
            ) {
                Button("OK", role: .cancel) { }
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
