import SwiftUI

struct ArchivedDataSymptomVisualizationView: View {
    @EnvironmentObject var archivedDataStore: ArchivedDataStore

    // Phases in the desired display order.
    let phases: [Event.EventType] = [.menstrual, .follicular, .ovulation, .luteal]
    
    // Map each phase to a display name.
    func displayName(for phase: Event.EventType) -> String {
        switch phase {
        case .menstrual: return "Menstruation"
        case .follicular: return "Follicular"
        case .ovulation: return "Ovulatory"
        case .luteal: return "Luteal"
        }
    }
    
    // Compute dynamic symptoms: the union of all non-empty tags from archived data, sorted by frequency.
    var symptoms: [String] {
        var frequency: [String: Int] = [:]
        for block in archivedDataStore.archivedBlocks {
            for phase in block.groupedEvents {
                for event in phase.events {
                    let eventTags = event.tags.split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    for tag in eventTags where !tag.isEmpty {
                        frequency[tag, default: 0] += 1
                    }
                }
            }
        }
        let sorted = frequency.sorted { $0.value > $1.value }
        return sorted.map { $0.key }
    }
    
    // Aggregate counts for a given phase based on the dynamic list of symptoms.
    func aggregatedCounts(for phase: Event.EventType) -> [String: Int] {
        var counts: [String: Int] = [:]
        // Initialize counts for each dynamic symptom.
        for symptom in symptoms {
            counts[symptom] = 0
        }
        // Iterate through all archived blocks.
        for block in archivedDataStore.archivedBlocks {
            if let phaseEvents = block.groupedEvents.first(where: { $0.eventType == phase }) {
                for event in phaseEvents.events {
                    let eventTags = event.tags.split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    for tag in eventTags {
                        if counts.keys.contains(tag) {
                            counts[tag, default: 0] += 1
                        }
                    }
                }
            }
        }
        return counts
    }
    
    // Compute the maximum count among all phases and dynamic symptoms for scaling the bars.
    var maxCount: Int {
        var maxVal = 0
        for phase in phases {
            let counts = aggregatedCounts(for: phase)
            for symptom in symptoms {
                maxVal = max(maxVal, counts[symptom] ?? 0)
            }
        }
        return maxVal > 0 ? maxVal : 1
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if archivedDataStore.archivedBlocks.isEmpty {
                    Text("No archived data exists")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(phases, id: \.self) { phase in
                            let phaseCounts = aggregatedCounts(for: phase)
                            VStack(alignment: .leading, spacing: 8) {
                                // Phase title
                                Text(displayName(for: phase))
                                    .font(.headline)
                                
                                // For each dynamic symptom with nonzero count, render a row.
                                ForEach(symptoms.filter { (phaseCounts[$0] ?? 0) > 0 }, id: \.self) { symptom in
                                    let count = phaseCounts[symptom] ?? 0
                                    HStack {
                                        // Display the symptom text in a fixed-width column.
                                        Text(symptom)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                            .frame(minWidth: 80, alignment: .leading)
                                        
                                        // The bar uses a GeometryReader to scale width proportionally.
                                        GeometryReader { geo in
                                            let barWidth = (CGFloat(count) / CGFloat(maxCount)) * geo.size.width
                                            ZStack(alignment: .leading) {
                                                Rectangle()
                                                    .foregroundColor(Color.gray.opacity(0.2))
                                                Rectangle()
                                                    .foregroundColor(Color(UIColor.systemBlue))
                                                    .frame(width: barWidth)
                                            }
                                        }
                                        .frame(height: 20)
                                    }
                                    .frame(height: 20)
                                }
                                
                                Divider()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Symptom Visualization")
        }
    }
}

struct ArchivedDataSymptomVisualizationView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample archived data for preview purposes.
        let sampleBlockMenstrual = ArchivedDataBlock(
            date: Date(),
            groupedEvents: [
                ArchivedDataBlock.PhaseEvents(
                    eventType: .menstrual,
                    events: [
                        Event(eventType: .menstrual, date: Date(), note: "", tags: "Cramps, Fatigue"),
                        Event(eventType: .menstrual, date: Date(), note: "", tags: "Cramps"),
                        Event(eventType: .menstrual, date: Date(), note: "", tags: "Fatigue"),
                        Event(eventType: .menstrual, date: Date(), note: "", tags: "Bloating"),
                        Event(eventType: .menstrual, date: Date(), note: "", tags: "Mood Swings"),
                        Event(eventType: .menstrual, date: Date(), note: "", tags: "Cramps")
                    ]
                )
            ]
        )
        
        let sampleBlockFollicular = ArchivedDataBlock(
            date: Date().addingTimeInterval(-86400),
            groupedEvents: [
                ArchivedDataBlock.PhaseEvents(
                    eventType: .follicular,
                    events: [
                        Event(eventType: .follicular, date: Date(), note: "", tags: "Cramps"),
                        Event(eventType: .follicular, date: Date(), note: "", tags: "Fatigue"),
                        Event(eventType: .follicular, date: Date(), note: "", tags: "Bloating"),
                        Event(eventType: .follicular, date: Date(), note: "", tags: "Mood Swings"),
                        Event(eventType: .follicular, date: Date(), note: "", tags: "Cramps")
                    ]
                )
            ]
        )
        
        let sampleBlockOvulatory = ArchivedDataBlock(
            date: Date().addingTimeInterval(-2 * 86400),
            groupedEvents: [
                ArchivedDataBlock.PhaseEvents(
                    eventType: .ovulation,
                    events: [
                        Event(eventType: .ovulation, date: Date(), note: "", tags: "Cramps"),
                        Event(eventType: .ovulation, date: Date(), note: "", tags: "Fatigue"),
                        Event(eventType: .ovulation, date: Date(), note: "", tags: "Bloating"),
                        Event(eventType: .ovulation, date: Date(), note: "", tags: "Mood Swings")
                    ]
                )
            ]
        )
        
        let sampleBlockLuteal = ArchivedDataBlock(
            date: Date().addingTimeInterval(-3 * 86400),
            groupedEvents: [
                ArchivedDataBlock.PhaseEvents(
                    eventType: .luteal,
                    events: [
                        Event(eventType: .luteal, date: Date(), note: "", tags: "Cramps"),
                        Event(eventType: .luteal, date: Date(), note: "", tags: "Cramps"),
                        Event(eventType: .luteal, date: Date(), note: "", tags: "Fatigue"),
                        Event(eventType: .luteal, date: Date(), note: "", tags: "Fatigue"),
                        Event(eventType: .luteal, date: Date(), note: "", tags: "Bloating"),
                        Event(eventType: .luteal, date: Date(), note: "", tags: "Mood Swings"),
                        Event(eventType: .luteal, date: Date(), note: "", tags: "Mood Swings")
                    ]
                )
            ]
        )
        
        let store = ArchivedDataStore()
        store.archivedBlocks = [sampleBlockMenstrual, sampleBlockFollicular, sampleBlockOvulatory, sampleBlockLuteal]
        
        return ArchivedDataSymptomVisualizationView()
            .environmentObject(store)
            .previewLayout(.sizeThatFits)
    }
}

