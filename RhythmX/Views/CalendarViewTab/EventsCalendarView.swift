//
//  EventsCalendarView.swift
//

import SwiftUI

struct EventsCalendarView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var dateSelected: DateComponents?
    @State private var displayEvents = false

    var body: some View {
        NavigationStack {
            ScrollView {
                CalendarView(
                    interval: DateInterval(start: .distantPast, end: .distantFuture),
                    eventStore: eventStore,
                    dateSelected: $dateSelected,
                    displayEvents: $displayEvents
                )
                // KEY CHANGE: Force a full reload each time `eventStore.shouldReloadAll` toggles
                .id(eventStore.shouldReloadAll)

                Image("launchScreen")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
            }
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
