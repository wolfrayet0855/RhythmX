//
//  LunarApp.swift
//  Lunar
//
//  Created by user on 9/27/24.
//

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
