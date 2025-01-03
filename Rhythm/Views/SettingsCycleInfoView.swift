//
//  SettingsCycleInfoView.swift
//

import SwiftUI

struct SettingsCycleInfoView: View {
    @EnvironmentObject var eventStore: EventStore

    @State private var selectedStartDate: Date = Date()
    @State private var selectedCycleLength: Int = 28

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
                        // Wrap in main queue to avoid "Publishing changes from within view updates" warnings
                        DispatchQueue.main.async {
                            eventStore.generateCycleEvents(
                                startDate: selectedStartDate,
                                cycleLength: selectedCycleLength
                            )
                        }
                    }) {
                        Text("Generate Cycle Events")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } footer: {
                    Text("This removes any pre-existing cycle events in the upcoming \(selectedCycleLength) days, then generates brand new ones.")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsCycleInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCycleInfoView()
            .environmentObject(EventStore(preview: true))
    }
}
