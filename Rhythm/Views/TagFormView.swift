///
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
    @State private var isAllDay = false

    var body: some View {
        NavigationStack {
            Form {
                Picker("Category", selection: $category) {
                    ForEach(TagCategory.allCases, id: \.self) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }

                TextField("Specific Type (e.g. chocolate)", text: $customType)

                DatePicker("Date", selection: $tagDate, displayedComponents: .date)

                Toggle("All Day?", isOn: $isAllDay)
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
        // Build the new tag: "Food:chocolate" (example)
        let newTag = "\(category.rawValue):\(customType.isEmpty ? "unspecified" : customType)"

        let targetStartOfDay = tagDate.startOfDay

        for event in myEvents.events {
            let eventStartOfDay = event.date.startOfDay

            if isAllDay {
                // Compare ignoring time
                if eventStartOfDay == targetStartOfDay {
                    var updated = event
                    if updated.tags.isEmpty {
                        updated.tags = newTag
                    } else {
                        updated.tags += ", \(newTag)"
                    }
                    myEvents.update(updated)
                }
            } else {
                // Compare exact day/hour/minute
                let sameDay = Calendar.current.isDate(event.date, inSameDayAs: tagDate)
                let sameHour = Calendar.current.component(.hour, from: event.date) == Calendar.current.component(.hour, from: tagDate)
                let sameMinute = Calendar.current.component(.minute, from: event.date) == Calendar.current.component(.minute, from: tagDate)

                if sameDay && sameHour && sameMinute {
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
}
