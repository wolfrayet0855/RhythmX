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

// MARK: - Archived Data Model
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

    // Keep track of archived data for building "Smart Tags"
    @State private var archivedDataBlocks: [TempArchivedDataBlock] = []
    @State private var smartTags: [String] = []
    
    // Suggestion dictionary for quick symptom selection
    private let phaseSymptomSuggestions: [Event.EventType: [String]] = [
        .menstrual:  ["Cramps", "Bloating", "Fatigue", "Headache", "Irritability"],
        .follicular: ["Increased Energy", "Clearer Thinking", "Higher Libido"],
        .ovulation:  ["Mittelschmerz", "Egg-White Mucus", "Bloating"],
        .luteal:     ["Mood Swings", "Breast Tenderness", "Food Cravings", "PMS"]
    ]

    // === NEW: Alert to stop duplicate tags on the same day ===
    @State private var showDuplicateTagAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Picker("Category", selection: $category) {
                    ForEach(TagCategory.allCases, id: \.self) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }
                
                TextField("Specific Type (e.g. 🍫)", text: $customType)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(false)
                    .keyboardType(.default)
                
                DatePicker("Date", selection: $tagDate, displayedComponents: .date)
                
                if let phaseType = currentPhaseType {
                    Section(header: Text("Suggested Tags for \(phaseType.rawValue.capitalized) Phase")) {
                        if let suggestions = phaseSymptomSuggestions[phaseType], !suggestions.isEmpty {
                            ForEach(suggestions, id: \.self) { suggestion in
                                Button {
                                    category = .symptom
                                    customType = suggestion
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

                if !smartTags.isEmpty {
                    Section(header: Text("Smart Tags (from Archive)")) {
                        ForEach(smartTags, id: \.self) { tagString in
                            Button {
                                applySmartTag(tagString)
                            } label: {
                                Text(tagString)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add a New Tag")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // === Check for duplicates first ===
                    Button("Save") {
                        if isDuplicateTag() {
                            showDuplicateTagAlert = true
                        } else {
                            saveTag()
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            // Show an alert if the user attempts a duplicate
            .alert("Duplicate Tag", isPresented: $showDuplicateTagAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("This tag already exists for the selected day.")
            }
            .onAppear {
                loadArchivedDataBlocks()
                buildSmartTags()
            }
            // If iOS 17 or later:
            .onChange(of: tagDate) { oldValue, newValue in
                buildSmartTags()
            }
        }
    }

    private var currentPhaseType: Event.EventType? {
        myEvents.events.first {
            $0.date.startOfDay == tagDate.startOfDay
        }?.eventType
    }
    
    // === NEW: Check if the tag already exists on this day across all events ===
    private func isDuplicateTag() -> Bool {
        let finalTag = buildTagString()
        let targetStartOfDay = tagDate.startOfDay

        // Gather all tags on this day from *all* events
        var dayWideTagSet = Set<String>()
        for event in myEvents.events where event.date.startOfDay == targetStartOfDay {
            let tagsArray = event.tags
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            for t in tagsArray {
                dayWideTagSet.insert(t)
            }
        }
        // Return true if we already have this exact tag
        return dayWideTagSet.contains(finalTag)
    }

    private func buildTagString() -> String {
        let sanitized = customType.isEmpty ? "unspecified" : customType
        return "\(category.rawValue):\(sanitized)"
    }

    private func saveTag() {
        let finalTag = buildTagString()
        let targetStartOfDay = tagDate.startOfDay

        // Append this new tag to *every* event on the chosen day
        for event in myEvents.events where event.date.startOfDay == targetStartOfDay {
            var updated = event
            if updated.tags.isEmpty {
                updated.tags = finalTag
            } else {
                updated.tags += ", \(finalTag)"
            }
            myEvents.update(updated)
        }
    }

    // === Called when user taps a "smart tag" button ===
    private func applySmartTag(_ tagString: String) {
        let parts = tagString.split(separator: ":", maxSplits: 1)
        if parts.count == 2 {
            let prefix = String(parts[0]).trimmingCharacters(in: .whitespacesAndNewlines)
            let suffix = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let matchedCategory = TagCategory.allCases.first(where: { $0.rawValue.lowercased() == prefix.lowercased() }) {
                category = matchedCategory
            } else {
                category = .other
            }
            customType = suffix
        } else {
            category = .other
            customType = tagString
        }
    }
}

// MARK: - ARCHIVED DATA + SMART TAGS
extension TagFormView {
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
    
    private func buildSmartTags() {
        guard let phaseType = currentPhaseType else {
            smartTags = []
            return
        }
        
        var frequency: [String: Int] = [:]
        
        for block in archivedDataBlocks {
            for archivedPhase in block.groupedEvents {
                guard archivedPhase.eventType == phaseType else { continue }
                
                for archivedEvent in archivedPhase.events {
                    let rawTags = archivedEvent.tags
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    for t in rawTags where !t.isEmpty {
                        frequency[t, default: 0] += 1
                    }
                }
            }
        }
        
        let sorted = frequency.sorted { $0.value > $1.value }
        let topTags = sorted.prefix(6).map { $0.key }
        
        self.smartTags = topTags
    }
}

