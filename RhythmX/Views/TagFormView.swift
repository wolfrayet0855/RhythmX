//
//
//  TagFormView.swift
//  Rhythm
//
//  Created by user on 9/27/24.
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

// MARK: - Archived Data Model (we reuse the same structs)
private struct TempArchivedDataBlock: Codable {
    let id: UUID
    let date: Date
    let groupedEvents: [TempPhaseEvents]
}

private struct TempPhaseEvents: Codable {
    let eventType: Event.EventType
    let events: [Event]
}

struct TagFormView: View {
    @EnvironmentObject var myEvents: EventStore
    @Environment(\.dismiss) var dismiss

    @State private var category: TagCategory = .dietary
    @State private var customType: String = ""
    @State private var tagDate = Date()

    // NEW: For retrieving archived data (to get “smart tags”).
    @State private var archivedDataBlocks: [TempArchivedDataBlock] = []
    // We'll store the top tags from archive here:
    @State private var smartTags: [String] = []
    
    // We'll define symptom suggestions for each phase:
    // You can expand/edit these as you like.
    private let phaseSymptomSuggestions: [Event.EventType: [String]] = [
        .menstrual:  ["Cramps", "Bloating", "Fatigue", "Headache", "Irritability"],
        .follicular: ["Increased Energy", "Clearer Thinking", "Higher Libido"],
        .ovulation:  ["Mittelschmerz", "Egg-White Mucus", "Bloating"],
        .luteal:     ["Mood Swings", "Breast Tenderness", "Food Cravings", "PMS"]
    ]

    /// We no longer show an "All Day" toggle; always all day.
    private let isAllDay = true

    var body: some View {
        NavigationStack {
            Form {
                // Choose a broad category
                Picker("Category", selection: $category) {
                    ForEach(TagCategory.allCases, id: \.self) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }
                
                // A free-form text for custom detail
                TextField("Specific Type (e.g. 🍫)", text: $customType)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(false)
                    .keyboardType(.default)
                
                // Pick a date
                DatePicker("Date", selection: $tagDate, displayedComponents: .date)
                
                // NEW: Show suggested tags for whichever phase is on the chosen date
                if let currentPhaseType = currentPhaseType {
                    Section(header: Text("Suggested Symptoms for \(currentPhaseType.rawValue.capitalized) Phase")) {
                        // Look up possible suggestions
                        if let suggestions = phaseSymptomSuggestions[currentPhaseType], !suggestions.isEmpty {
                            ForEach(suggestions, id: \.self) { suggestion in
                                Button {
                                    addSuggestionToCustomType(suggestion)
                                } label: {
                                    Text(suggestion)
                                }
                            }
                        } else {
                            Text("No suggestions available for this phase.")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // NEW: Show “Smart Tags” from archived data
                if !smartTags.isEmpty {
                    Section(header: Text("Smart Tags (from Archive)")) {
                        ForEach(smartTags, id: \.self) { tag in
                            Button {
                                addSuggestionToCustomType(tag)
                            } label: {
                                Text(tag)
                            }
                        }
                    }
                }
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
            // NEW: Load archived data and build smart tags once this view appears
            .onAppear {
                loadArchivedDataBlocks()
                buildSmartTags()
            }
        }
    }

    /// Attempts to find an event for the chosen date, returning that event's phase type.
    private var currentPhaseType: Event.EventType? {
        let matchedEvent = myEvents.events.first {
            $0.date.startOfDay == tagDate.startOfDay
        }
        return matchedEvent?.eventType
    }
    
    /// Append a selected suggestion (either from suggested symptoms or from smart tags)
    /// into the `customType` field.
    private func addSuggestionToCustomType(_ suggestion: String) {
        if customType.isEmpty {
            customType = suggestion
        } else {
            customType += ", \(suggestion)"
        }
    }

    /// Saves the new tag to any Event that matches `tagDate`.
    private func saveTag() {
        // e.g. if category = "Dietary" and customType = "🍫",
        // then final "tag" is "Dietary:🍫"
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

// MARK: - ARCHIVED DATA LOADING + SMART TAGS
extension TagFormView {
    /// Loads archived data from UserDefaults (same key as in `SettingsCycleInfoView`).
    private func loadArchivedDataBlocks() {
        let archivedDataKey = "com.example.rhythm(x).archivedData"
        guard let data = UserDefaults.standard.data(forKey: archivedDataKey) else { return }
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode([TempArchivedDataBlock].self, from: data)
            archivedDataBlocks = decoded
        } catch {
            print("Error decoding archived data for TagFormView: \(error)")
            archivedDataBlocks = []
        }
    }
    
    /// Gather all tags from archived events, count frequency, and store top items in `smartTags`.
    private func buildSmartTags() {
        var frequency: [String: Int] = [:]
        
        // Loop all archived blocks -> phases -> events
        for block in archivedDataBlocks {
            for phase in block.groupedEvents {
                for archivedEvent in phase.events {
                    // Each event may have multiple tags, separated by commas
                    let rawTags = archivedEvent.tags
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    for t in rawTags where !t.isEmpty {
                        frequency[t, default: 0] += 1
                    }
                }
            }
        }
        // Sort by usage (descending). Keep top ~6
        let sorted = frequency.sorted { $0.value > $1.value }
        let top = sorted.prefix(6).map { $0.key }
        
        self.smartTags = top
    }
}
