//
//  TagFormView.swift
//

import SwiftUI

enum TagCategory: String, CaseIterable {
    case dietary = "Dietary"
    case exercise = "Exercise"
    case medication = "Medication"
    case mood = "Mood"
    case symptom = "Symptom"
    case other = "Other"
}

struct TagFormView: View {
    @EnvironmentObject var myEvents: EventStore
    @Environment(\.dismiss) var dismiss

    @State private var category: TagCategory = .dietary
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

                //    any autocapitalization and allowing default keyboard (which includes emojis)
                TextField("Specific Type (e.g. 🍫)", text: $customType)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(false)
                    .keyboardType(.default)
                // 2) DatePicker for date only
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
        // e.g. "Dietary:🍫" if the user typed "🍫"
        let newTag = "\(category.rawValue):\(customType.isEmpty ? "unspecified" : customType)"

        let targetStartOfDay = tagDate.startOfDay

        for event in myEvents.events {
            let eventStartOfDay = event.date.startOfDay
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

