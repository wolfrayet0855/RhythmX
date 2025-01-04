//
//  ListViewRow.swift
//

import SwiftUI

struct ListViewRow: View {
    let event: Event
    @Binding var formType: EventFormType?

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(event.eventType.icon)
                        .font(.system(size: 40))
                    Text("\(event.eventType.rawValue.capitalized) Phase")
                }
                Text(event.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !event.tags.isEmpty {
                    Text("Tags: \(event.tags)")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
            }
            Spacer()
            Button("Edit") {
                formType = .update(event)
            }
            .buttonStyle(.bordered)
        }
    }
}

struct ListViewRow_Previews: PreviewProvider {
    static let sampleEvent = Event(
        eventType: .menstrual,
        date: Date(),
        note: "Example note",
        tags: "cramping, chocolate"
    )
    static var previews: some View {
        ListViewRow(event: sampleEvent, formType: .constant(.new))
    }
}
