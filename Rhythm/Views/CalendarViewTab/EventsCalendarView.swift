//
//  EventsCalendarView.swift
//

import SwiftUI

struct EventsCalendarView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var dateSelected: DateComponents?
    @State private var displayEvents = false
    // Remove formType and the plus button altogether
    // @State private var formType: EventFormType?

    var body: some View {
        NavigationStack {
            ScrollView {
                CalendarView(
                    interval: DateInterval(start: .distantPast, end: .distantFuture),
                    eventStore: eventStore,
                    dateSelected: $dateSelected,
                    displayEvents: $displayEvents
                )
                Image("launchScreen")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
            }
            // Removed toolbar with "plus.circle.fill"
            .sheet(isPresented: $displayEvents) {
                DaysEventsListView(dateSelected: $dateSelected)
                    .presentationDetents([.medium, .large])
            }
            .navigationTitle("Calendar View")
        }
    }
}

struct EventsCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        EventsCalendarView()
            .environmentObject(EventStore(preview: true))
    }
}
