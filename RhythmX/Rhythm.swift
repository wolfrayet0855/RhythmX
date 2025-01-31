//
//  AppEntry.swift
//

import SwiftUI

@main
struct AppEntry: App {
    @StateObject var myEvents = EventStore(preview: false)
    
    // ADD: One instance of ArchivedDataStore for the entire app
    @StateObject var archivedDataStore = ArchivedDataStore()

    @AppStorage("didFinishOnboarding") var didFinishOnboarding = false
    @AppStorage("selectedTab") var selectedTab = 0

    var body: some Scene {
        WindowGroup {
            if didFinishOnboarding {
                StartTabView()
                    .environmentObject(myEvents)
                    .environmentObject(archivedDataStore)  // Provide to child views
            } else {
                OnboardingView()
                    .environmentObject(myEvents)
                    .environmentObject(archivedDataStore)
            }
        }
    }
}
