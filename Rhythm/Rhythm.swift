//  rhythm.swift


import SwiftUI

@main
struct AppEntry: App {
    @StateObject var myEvents = EventStore(preview: true)

    var body: some Scene {
        WindowGroup {
            StartTabView()
                .environmentObject(myEvents)
        }
    }
}
