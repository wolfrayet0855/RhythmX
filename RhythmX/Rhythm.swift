//
//  AppEntry.swift
//

import SwiftUI

@main
struct AppEntry: App {
    @StateObject var myEvents          = EventStore(preview: false)
    @StateObject var archivedDataStore = ArchivedDataStore()
    @StateObject var appSettings       = AppSettings()

    @AppStorage("didFinishOnboarding") var didFinishOnboarding = false

    var body: some Scene {
        WindowGroup {
            if didFinishOnboarding {
                StartTabView()
                    .environmentObject(myEvents)
                    .environmentObject(archivedDataStore)
                    .environmentObject(appSettings)
            } else {
                OnboardingView()
                    .environmentObject(myEvents)
                    .environmentObject(archivedDataStore)
                    .environmentObject(appSettings)
            }
        }
    }
}
