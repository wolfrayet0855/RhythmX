import SwiftUI
import Charts

struct ArchivedDataVisualizationView: View {
    @EnvironmentObject var archivedDataStore: ArchivedDataStore

    // A simple model for chart data
    struct ChartEntry: Identifiable {
        let id = UUID()
        let archiveDate: Date
        let eventType: Event.EventType
        let count: Int
    }

    // Transform each archived block into one or more chart entries.
    // For each block, we list the count of events in each phase.
    var chartData: [ChartEntry] {
        archivedDataStore.archivedBlocks.flatMap { block in
            block.groupedEvents.map { phase in
                ChartEntry(
                    archiveDate: block.date,
                    eventType: phase.eventType,
                    count: phase.events.count
                )
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if archivedDataStore.archivedBlocks.isEmpty {
                    Text("No archived data exists")
                        .font(.title)
                        .foregroundColor(.secondary)
                } else {
                    Chart {
                        ForEach(chartData) { entry in
                            BarMark(
                                x: .value("Archive Date", entry.archiveDate, unit: .day),
                                y: .value("Count", entry.count)
                            )
                            .foregroundStyle(by: .value("Event Type", entry.eventType.rawValue.capitalized))
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 5)) { value in
                            AxisValueLabel() {
                                if let date = value.as(Date.self) {
                                    Text(date, format: .dateTime.month(.abbreviated).day())
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Archived Data Visualization")
        }
    }
}

struct ArchivedDataVisualizationView_Previews: PreviewProvider {
    static var previews: some View {
        // Create sample archived data for preview
        let sampleArchiveBlock = ArchivedDataBlock(
            date: Date(),
            groupedEvents: [
                ArchivedDataBlock.PhaseEvents(
                    eventType: .menstrual,
                    events: Array(repeating: Event(eventType: .menstrual, date: Date(), note: "Sample", tags: ""), count: 3)
                ),
                ArchivedDataBlock.PhaseEvents(
                    eventType: .ovulation,
                    events: Array(repeating: Event(eventType: .ovulation, date: Date(), note: "Sample", tags: ""), count: 2)
                )
            ]
        )
        let store = ArchivedDataStore()
        store.archivedBlocks = [sampleArchiveBlock]
        
        return ArchivedDataVisualizationView()
            .environmentObject(store)
    }
}
