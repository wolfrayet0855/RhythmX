//  EventsCalendarView.swift

import SwiftUI

struct EventsCalendarView: View {
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var archivedDataStore: ArchivedDataStore
    @EnvironmentObject var appSettings: AppSettings
    @State private var dateSelected: DateComponents?
    @State private var displayEvents = false
    @State private var showNotificationPrompt = false

    private var daysUntilPrediction: Int? {
        CyclePredictionService.daysUntilPrediction(from: archivedDataStore.archivedBlocks)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let days = daysUntilPrediction, days >= 0, days <= 3 {
                    PredictionBannerView(daysUntil: days)
                }

                CalendarView(
                    interval: DateInterval(start: .distantPast, end: .distantFuture),
                    eventStore: eventStore,
                    dateSelected: $dateSelected,
                    displayEvents: $displayEvents
                )
                .id("\(eventStore.shouldReloadAll)-\(appSettings.phaseColor1)-\(appSettings.phaseColor2)-\(appSettings.phaseColor3)-\(appSettings.phaseColor4)")

                Image("launchScreen")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
            }
            .sheet(isPresented: $displayEvents) {
                DaysEventsListView(dateSelected: $dateSelected)
                    .presentationDetents([.medium, .large])
            }
            .navigationTitle("Calendar")
            .alert("Cycle Reminders", isPresented: $showNotificationPrompt) {
                Button("Enable") {
                    NotificationScheduler.requestPermissionIfNeeded { granted in
                        if granted {
                            UserDefaults.standard.set(true, forKey: "notificationsEnabled")
                            if let predicted = CyclePredictionService.predictedStartDate(from: archivedDataStore.archivedBlocks) {
                                NotificationScheduler.scheduleCycleReminders(
                                    for: predicted, dayBefore: true, dayOf: true
                                )
                            }
                        }
                    }
                }
                Button("Not Now", role: .cancel) {}
            } message: {
                Text("Want reminders when your next cycle is near?")
            }
            .onReceive(NotificationCenter.default.publisher(for: .rhythmxPromptNotifications)) { _ in
                showNotificationPrompt = true
            }
        }
    }
}

#Preview {
    EventsCalendarView()
        .environmentObject(EventStore(preview: true))
        .environmentObject(ArchivedDataStore())
        .environmentObject(AppSettings())
}
