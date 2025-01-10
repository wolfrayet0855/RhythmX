//
//  TagFormView.swift
//

import SwiftUI

enum TagCategory: String, CaseIterable {
    case emotion = "Emotion"
    case food = "Food"
    case exercise = "Exercise"
    case medication = "Medication"
    case other = "Other"
}

struct TagFormView: View {
    @EnvironmentObject var myEvents: EventStore
    @Environment(\.dismiss) var dismiss

    @State private var category: TagCategory = .food
    @State private var customType: String = ""
    @State private var tagDate = Date()
    
    /// No toggle anymore; we always do "all day"
    private let isAllDay = true

    var body: some View {
        NavigationStack {
            Form {
                Picker("Category", selection: $category) {
                    ForEach(TagCategory.allCases, id: \.self) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }

                TextField("Specific Type (e.g. chocolate)", text: $customType)

                // DatePicker for date only
                DatePicker("Date", selection: $tagDate, displayedComponents: .date)
            }
            .navigationTitle("Add a New Tag")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTag()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveTag() {
        // e.g. "Food:chocolate" if customType == "chocolate"
        let newTag = "\(category.rawValue):\(customType.isEmpty ? "unspecified" : customType)"

        // We'll always compare ignoring the time
        let targetStartOfDay = tagDate.startOfDay

        for event in myEvents.events {
            let eventStartOfDay = event.date.startOfDay

            // If the event is on the same day, attach the tag
            if eventStartOfDay == targetStartOfDay {
                var updated = event
                if updated.tags.isEmpty {
                    updated.tags = newTag
                } else {
                    updated.tags += ", \(newTag)"
                }
                myEvents.update(updated)
            }
        }
    }
}
