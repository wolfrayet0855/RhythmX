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
                    DatePicker("Date and Time", selection: $viewModel.date)
                    
                    Picker("Phase Type", selection: $viewModel.eventType) {
                        ForEach(Event.EventType.allCases) { et in
                            Text(et.icon + " " + et.rawValue.capitalized)
                                .tag(et)
                        }
                    }

                    TextField("Note", text: $viewModel.note, axis: .vertical)
                        .focused($focus, equals: true)

                    // Freeform tags
                    TextField("Custom Tags (freeform)", text: $viewModel.tags)
                        .focused($focus, equals: false)

                    Section(footer:
                        HStack {
                            Spacer()
                            Button {
                                if viewModel.updating {
                                    let updated = Event(
                                        id: viewModel.id!,
                                        eventType: viewModel.eventType,
                                        date: viewModel.date,
                                        note: viewModel.note,
                                        tags: viewModel.tags
                                    )
                                    eventStore.update(updated)
                                } else {
                                    let newEvent = Event(
                                        eventType: viewModel.eventType,
                                        date: viewModel.date,
                                        note: viewModel.note,
                                        tags: viewModel.tags
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
