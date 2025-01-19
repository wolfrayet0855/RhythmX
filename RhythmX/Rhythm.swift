//
//  AppEntry.swift
//

import SwiftUI

@main
struct AppEntry: App {
    @StateObject var myEvents = EventStore(preview: false)
    
    // Tracks whether user has completed onboarding
    @AppStorage("didFinishOnboarding") var didFinishOnboarding = false

    // Tracks which tab to show in StartTabView (0 = first tab, 1 = second, 2 = Settings, etc.)
    @AppStorage("selectedTab") var selectedTab = 0

    var body: some Scene {
        WindowGroup {
            if didFinishOnboarding {
                // The user is done with onboarding; show main app
                StartTabView()
                    .environmentObject(myEvents)
            } else {
                // Show Onboarding
                OnboardingView()
                    .environmentObject(myEvents)
            }
        }
    }
}


