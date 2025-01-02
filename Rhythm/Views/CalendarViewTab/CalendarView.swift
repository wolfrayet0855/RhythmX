//
//  CalendarView.swift
//

import SwiftUI

struct CalendarView: UIViewRepresentable {
    // This tells SwiftUI what the "underlying" UIView is
    typealias UIViewType = UICalendarView

    let interval: DateInterval
    @ObservedObject var eventStore: EventStore
    @Binding var dateSelected: DateComponents?
    @Binding var displayEvents: Bool

    // MARK: - makeUIView
    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.delegate = context.coordinator
        view.calendar = Calendar(identifier: .gregorian)
        view.availableDateRange = interval

        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.selectionBehavior = dateSelection

        return view
    }

    // MARK: - updateUIView
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // If an event was changed, reload the relevant date decorations
        if let changedEvent = eventStore.changedEvent {
            uiView.reloadDecorations(
                forDateComponents: [changedEvent.dateComponents],
                animated: true
            )
            eventStore.changedEvent = nil
        }

        // If an event was "moved," also reload
        if let movedEvent = eventStore.movedEvent {
            uiView.reloadDecorations(
                forDateComponents: [movedEvent.dateComponents],
                animated: true
            )
            eventStore.movedEvent = nil
        }
    }

    // MARK: - makeCoordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, eventStore: _eventStore)
    }

    // MARK: - Coordinator
    class Coordinator: NSObject,
                       @preconcurrency UICalendarViewDelegate,
                       UICalendarSelectionSingleDateDelegate
    {
        var parent: CalendarView
        @ObservedObject var eventStore: EventStore

        init(parent: CalendarView, eventStore: ObservedObject<EventStore>) {
            self.parent = parent
            self._eventStore = eventStore
        }
        
        @MainActor
        func calendarView(_ calendarView: UICalendarView,
                          decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            let foundEvents = eventStore.events.filter {
                $0.date.startOfDay == dateComponents.date?.startOfDay
            }
            if foundEvents.isEmpty { return nil }

            if foundEvents.count > 1 {
                // Example decoration for multiple events on one date
                return .image(
                    UIImage(systemName: "doc.on.doc.fill"),
                    color: .red,
                    size: .large
                )
            }

            // Show icon for a single event
            if let singleEvent = foundEvents.first {
                return .customView {
                    let icon = UILabel()
                    icon.text = singleEvent.eventType.icon
                    return icon
                }
            }
            return nil
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate,
                           didSelectDate dateComponents: DateComponents?) {
            parent.dateSelected = dateComponents
            guard let dateComponents else { return }

            let foundEvents = eventStore.events.filter {
                $0.date.startOfDay == dateComponents.date?.startOfDay
            }
            // Show the day's events if found
            if !foundEvents.isEmpty {
                parent.displayEvents.toggle()
            }
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate,
                           canSelectDate dateComponents: DateComponents?) -> Bool {
            return true
        }
    }
}
