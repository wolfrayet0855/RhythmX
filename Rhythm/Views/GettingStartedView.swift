//
//  GettingStartedView.swift
//

import SwiftUI

struct GettingStartedView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Getting Started")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 8)

                // Step 1
                Text("1) Generate Cycle Events")
                    .font(.headline)
                Text("Go to the 'Generate Events' section in Settings and tap the button. This will populate your calendar with your phases for the chosen cycle length.")

                // Step 2
                Text("2) Add Tags")
                    .font(.headline)
                Text("Use the 'Events List' tab to add new tags, such as emotions or cravings. Tap the (+) icon at the top to add a tag to your chosen date.")

                // Step 3
                Text("3) Check Out the Calendar")
                    .font(.headline)
                Text("Open the 'Calendar' tab to see your phases and any events with tags. Tap a date to view or edit tags for that day.")

                // Step 4
                Text("4) Learn About Phases")
                    .font(.headline)
                Text("In Settings, navigate to 'Menstrual Phases Info' for a detailed explanation of each phase and what to expect.")

                // Add any more steps or tips as needed
            }
            .padding()
        }
        .navigationTitle("Getting Started")
    }
}

struct GettingStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GettingStartedView()
    }
}
