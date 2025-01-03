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
            uiView.reloadDecorations(
                forDateComponents: [changedEvent.dateComponents],
                animated: true
            )
            eventStore.changedEvent = nil
        }

        if let movedEvent = eventStore.movedEvent {
            uiView.reloadDecorations(
                forDateComponents: [movedEvent.dateComponents],
                animated: true
            )
            eventStore.movedEvent = nil
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, @preconcurrency UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        let parent: CalendarView

        init(parent: CalendarView) {
            self.parent = parent
        }

        @MainActor func calendarView(_ calendarView: UICalendarView,
                                     decorationFor dateComponents: DateComponents)
        -> UICalendarView.Decoration? {
            let foundEvents = parent.eventStore.events.filter {
                $0.date.startOfDay == dateComponents.date?.startOfDay
            }
            if foundEvents.isEmpty {
                return nil
            }
            if foundEvents.count > 1 {
                return .image(
                    UIImage(systemName: "doc.on.doc.fill"),
                    color: .red,
                    size: .large
                )
            }
            if let singleEvent = foundEvents.first {
                return .customView {
                    let label = UILabel()
                    label.text = singleEvent.eventType.icon
                    return label
                }
            }
            return nil
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate,
                           didSelectDate dateComponents: DateComponents?) {
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

        func dateSelection(_ selection: UICalendarSelectionSingleDate,
                           canSelectDate dateComponents: DateComponents?) -> Bool {
            true
        }
    }
}
