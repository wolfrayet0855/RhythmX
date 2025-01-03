//
//  EventFormView.swift
//

import SwiftUI

struct EventFormView: View {
    @EnvironmentObject var eventStore: EventStore
    @StateObject var viewModel: EventFormViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focus: Bool?

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    DatePicker(selection: $viewModel.date) {
                        Text("Date and Time")
                    }
                    Picker("Phase Type", selection: $viewModel.eventType) {
                        ForEach(Event.EventType.allCases) { eventType in
                            Text(eventType.icon + " " + eventType.rawValue.capitalized)
                                .tag(eventType)
                        }
                    }
                    TextField("Note", text: $viewModel.note, axis: .vertical)
                        .focused($focus, equals: true)
                    
                    Section(footer:
                        HStack {
                            Spacer()
                            Button {
                                if viewModel.updating {
                                    let event = Event(
                                        id: viewModel.id!,
                                        eventType: viewModel.eventType,
                                        date: viewModel.date,
                                        note: viewModel.note
                                    )
                                    eventStore.update(event)
                                } else {
                                    let newEvent = Event(
                                        eventType: viewModel.eventType,
                                        date: viewModel.date,
                                        note: viewModel.note
                                    )
                                    eventStore.add(newEvent)
                                }
                                dismiss()
                            } label: {
                                Text(viewModel.updating ? "Update Event" : "Add Event")
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.incomplete)
                            Spacer()
                        }
                    ) {
                        EmptyView()
                    }
                }
            }
            .navigationTitle(viewModel.updating ? "Update" : "New Event")
            .onAppear {
                focus = true
            }
        }
    }
}

struct EventFormView_Previews: PreviewProvider {
    static var previews: some View {
        EventFormView(viewModel: EventFormViewModel())
            .environmentObject(EventStore())
    }
}
