//  GettingStartedView.swift
//

import SwiftUI

struct GettingStartedView: View {
    // After reading the steps, user can tap "Done"
    @AppStorage("didFinishOnboarding") var didFinishOnboarding = false
    @AppStorage("selectedTab") var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("1) Generate Cycle Events")
                    .font(.headline)
                Text("In Settings, tap ‘Generate Events’ to populate your calendar with your chosen cycle length.")

                Text("2) Add Tags")
                    .font(.headline)
                Text("Use the ‘Events List’ tab to add new tags (e.g., Dietary, Mood). Tap the plus (+) button to attach a tag to a date.")

                Text("3) Check Calendar")
                    .font(.headline)
                Text("In the ‘Calendar’ tab, see your phases & events. Tap a date to view/edit tags.")

                Text("4) Archive Data")
                    .font(.headline)
                Text("Each month in Settings, archive your previous data and generate new menstrual phase events. Use the Archive Data view to explore trends in your tags.")

                Text("5) Learn More")
                    .font(.headline)
                Text("In Settings, open ‘Menstrual Phases Info’ for details on each phase.")
            }
            .padding()
        }
        .navigationTitle("Getting Started")
        // We do NOT hide the back button, so user can return to OnboardingView
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    // Mark onboarding finished + jump them to Settings tab
                    selectedTab = 2
                    didFinishOnboarding = true
                }
            }
        }
    }
}

struct GettingStartedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GettingStartedView()
        }
    }
}
