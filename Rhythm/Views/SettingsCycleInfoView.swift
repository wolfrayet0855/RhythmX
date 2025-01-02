//
//  SettingsCycleInfoView.swift
//  Rhythm
//
//  Created by user on 1/2/25.
//


import SwiftUI

struct SettingsCycleInfoView: View {
    @EnvironmentObject var eventStore: EventStore

    // Defaults to "today" for the last menstrual date
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
                    Button(action: generateCycle) {
                        Text("Generate Cycle Events")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } footer: {
                    Text("This replaces any existing events with new ones representing your phases for the next cycle.")
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func generateCycle() {
        eventStore.generateCycleEvents(startDate: selectedStartDate,
                                       cycleLength: selectedCycleLength)
    }
}

struct SettingsCycleInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCycleInfoView()
            .environmentObject(EventStore(preview: true))
    }
}
