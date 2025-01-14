//
//  StartTabView.swift
//

import SwiftUI

struct StartTabView: View {
    // Controls which tab is selected
    @AppStorage("selectedTab") private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            EventsListView()
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
                .tag(0)

            EventsCalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(1)

            SettingsCycleInfoView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
    }
}

struct StartTabView_Previews: PreviewProvider {
    static var previews: some View {
        StartTabView()
            .environmentObject(EventStore(preview: true))
    }
}
