//
//  CalendarView.swift
//

import SwiftUI

struct CalendarView: UIViewRepresentable {
    typealias UIViewType = UICalendarView

    let interval: DateInterval
    @ObservedObject var eventStore: EventStore
    @Binding var dateSelected: DateComponents?
    @Binding var displayEvents: Bool

    func makeUIView(context: Context) -> UICalendarView {
        let uiCalendar = UICalendarView()
        uiCalendar.delegate = context.coordinator
        uiCalendar.calendar = Calendar(identifier: .gregorian)
        uiCalendar.availableDateRange = interval

        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        uiCalendar.selectionBehavior = dateSelection
        return uiCalendar
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        if let changedEvent = eventStore.changedEvent {
            uiView.reloadDecorations(forDateComponents: [changedEvent.dateComponents], animated: true)
            DispatchQueue.main.async {
                eventStore.changedEvent = nil
            }
        }

        if let movedEvent = eventStore.movedEvent {
            uiView.reloadDecorations(forDateComponents: [movedEvent.dateComponents], animated: true)
            DispatchQueue.main.async {
                eventStore.movedEvent = nil
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate  {
        let parent: CalendarView

        init(parent: CalendarView) {
            self.parent = parent
        }

        @MainActor func calendarView(
            _ calendarView: UICalendarView,
            decorationFor dateComponents: DateComponents
        ) -> UICalendarView.Decoration? {
            guard let event = parent.eventStore.events.first(where: {
                $0.date.startOfDay == dateComponents.date?.startOfDay
            }) else { return nil }

            return .customView {
                let size: CGFloat = 20
                let container = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
                container.backgroundColor = UIColor(event.eventType.phaseColor)
                container.layer.cornerRadius = size / 2
                container.clipsToBounds = true

                let label = UILabel(frame: container.bounds)
                label.text = "\(event.eventType.phaseNumber)"
                label.textColor = .white
                label.font = .boldSystemFont(ofSize: 11)
                label.textAlignment = .center
                container.addSubview(label)
                return container
            }
        }

        func dateSelection(
            _ selection: UICalendarSelectionSingleDate,
            didSelectDate dateComponents: DateComponents?
        ) {
            DispatchQueue.main.async {
                self.parent.dateSelected = dateComponents
                guard let dateComponents else { return }
                let foundEvents = self.parent.eventStore.events.filter {
                    $0.date.startOfDay == dateComponents.date?.startOfDay
                }
                if !foundEvents.isEmpty {
                    self.parent.displayEvents.toggle()
                }
            }
        }

        func dateSelection(
            _ selection: UICalendarSelectionSingleDate,
            canSelectDate dateComponents: DateComponents?
        ) -> Bool {
            true
        }
    }
}
