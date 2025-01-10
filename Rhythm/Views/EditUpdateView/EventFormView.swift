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

                    TextField("Custom Tags (freeform)", text: $viewModel.tags)
                        .focused($focus, equals: false)

                    Section(footer:
                        HStack {
                            Spacer()
                            Button {
                                // Only allow "update" scenario
                                if viewModel.updating {
                                    let updated = Event(
                                        id: viewModel.id!,
                                        eventType: viewModel.eventType,
                                        date: viewModel.date,
                                        note: viewModel.note,
                                        tags: viewModel.tags
                                    )
                                    eventStore.update(updated)
                                    dismiss()
                                } else {
                                    // NO-OP (ignore attempts to add brand-new event)
                                }
                            } label: {
                                Text("Update Event")
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(!viewModel.updating || viewModel.incomplete)
                            Spacer()
                        }
                    ) {
                        EmptyView()
                    }
                }
            }
            .navigationTitle("Edit Event")
            .onAppear {
                focus = true
            }
        }
    }
}

struct EventFormView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide an event so we're "updating"
        let sampleEvent = Event(
            eventType: .menstrual,
            date: Date(),
            note: "Sample edit",
            tags: "example"
        )
        EventFormView(viewModel: EventFormViewModel(sampleEvent))
            .environmentObject(EventStore())
    }
}
