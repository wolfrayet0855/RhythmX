//  InsightsView.swift

import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject var archivedDataStore: ArchivedDataStore
    @EnvironmentObject var myEvents: EventStore

    @State private var selectedPhase: Event.EventType? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                if archivedDataStore.archivedBlocks.isEmpty && myEvents.events.isEmpty {
                    emptyState
                } else {
                    VStack(alignment: .leading, spacing: DS.Spacing.xl) {
                        if !archivedDataStore.archivedBlocks.isEmpty {
                            tagFrequencyChart
                            Divider()
                            cycleLengthChart
                            Divider()
                        }
                        if !myEvents.events.isEmpty {
                            fertilityWindowChart
                            Divider()
                            cervicalMucusChart
                        }
                    }
                    .padding(DS.Spacing.md)
                }
            }
            .background(DS.Color.pageBackground.ignoresSafeArea())
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: DS.Spacing.md) {
            Spacer(minLength: DS.Spacing.xxl)
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 48))
                .foregroundColor(DS.Color.secondaryText)
            Text("No Insights Yet")
                .font(DS.Font.sectionHeader)
                .foregroundColor(DS.Color.primaryText)
            Text("Generate and archive your first cycle to see your patterns here.")
                .font(DS.Font.label)
                .foregroundColor(DS.Color.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Spacing.xl)
            Spacer(minLength: DS.Spacing.xxl)
        }
    }

    // MARK: - Chart 1: Tag Frequency by Phase
    private var tagFrequencyChart: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("Tag Frequency by Phase")
                .font(DS.Font.sectionHeader)
                .foregroundColor(DS.Color.primaryText)
            Text("Total tags logged per phase across all archived cycles.")
                .font(DS.Font.caption)
                .foregroundColor(DS.Color.secondaryText)

            Chart {
                ForEach(tagFrequencyData, id: \.phase) { item in
                    BarMark(
                        x: .value("Phase", item.phaseName),
                        y: .value("Tags", item.count)
                    )
                    .foregroundStyle(item.color)
                    .cornerRadius(4)
                }
            }
            .frame(height: 200)

            if let phase = selectedPhase {
                let top = topTags(for: phase)
                if !top.isEmpty {
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text("Top tags — \(phase.displayName)")
                            .font(DS.Font.caption.weight(.semibold))
                            .foregroundColor(DS.Color.primaryText)
                        ForEach(top, id: \.tag) { item in
                            HStack {
                                Text(item.tag)
                                    .font(DS.Font.caption)
                                    .foregroundColor(DS.Color.primaryText)
                                Spacer()
                                Text("\(item.count)×")
                                    .font(DS.Font.micro)
                                    .foregroundColor(DS.Color.secondaryText)
                            }
                        }
                    }
                    .padding(DS.Spacing.sm)
                    .background(DS.Color.cardBackground)
                    .cornerRadius(DS.Radius.chip)
                }
            }

            HStack(spacing: DS.Spacing.md) {
                ForEach(Event.EventType.allCases, id: \.self) { phase in
                    Button {
                        selectedPhase = selectedPhase == phase ? nil : phase
                    } label: {
                        HStack(spacing: DS.Spacing.xs) {
                            Circle()
                                .fill(phase.phaseColor)
                                .frame(width: 10, height: 10)
                            Text("Phase \(phase.phaseNumber)")
                                .font(DS.Font.micro)
                                .foregroundColor(DS.Color.secondaryText)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Chart 2: Cycle Length Over Time
    @ViewBuilder
    private var cycleLengthChart: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("Cycle Length Over Time")
                .font(DS.Font.sectionHeader)
                .foregroundColor(DS.Color.primaryText)

            if cycleLengthData.count < 2 {
                placeholderCard(
                    icon: "waveform.path.ecg",
                    message: "Archive 2 or more cycles to see length trends."
                )
            } else {
                let avg = cycleLengthData.map(\.days).reduce(0, +) / cycleLengthData.count
                Text("Average: \(avg) days")
                    .font(DS.Font.caption)
                    .foregroundColor(DS.Color.secondaryText)

                Chart {
                    ForEach(cycleLengthData) { item in
                        LineMark(
                            x: .value("Cycle", item.label),
                            y: .value("Days", item.days)
                        )
                        .foregroundStyle(Color.accentColor)
                        .symbol(.circle)
                    }
                    RuleMark(y: .value("Average", avg))
                        .foregroundStyle(Color.accentColor.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                }
                .frame(height: 180)
            }
        }
    }

    // MARK: - Chart 3: Fertility Window
    @ViewBuilder
    private var fertilityWindowChart: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("Fertility Window")
                .font(DS.Font.sectionHeader)
                .foregroundColor(DS.Color.primaryText)
            Text("Ovulation day and fertile days in your current cycle.")
                .font(DS.Font.caption)
                .foregroundColor(DS.Color.secondaryText)

            let segments = fertilitySegments
            if segments.isEmpty {
                placeholderCard(icon: "circle.dotted", message: "Generate a cycle to see your fertility window.")
            } else {
                Chart(segments) { seg in
                    SectorMark(
                        angle: .value("Days", seg.days),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(seg.color)
                    .cornerRadius(4)
                }
                .frame(height: 200)

                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    ForEach(segments) { seg in
                        HStack(spacing: DS.Spacing.sm) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(seg.color)
                                .frame(width: 14, height: 14)
                            Text(seg.label)
                                .font(DS.Font.caption)
                                .foregroundColor(DS.Color.primaryText)
                            Spacer()
                            Text("\(seg.days) days")
                                .font(DS.Font.micro)
                                .foregroundColor(DS.Color.secondaryText)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Chart 4: Cervical Mucus
    @ViewBuilder
    private var cervicalMucusChart: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("Cervical Mucus")
                .font(DS.Font.sectionHeader)
                .foregroundColor(DS.Color.primaryText)
            Text("Mucus consistency logged across cycle days.")
                .font(DS.Font.caption)
                .foregroundColor(DS.Color.secondaryText)

            let data = cervicalMucusData
            if data.isEmpty {
                placeholderCard(
                    icon: "drop",
                    message: "Log cervical mucus tags to track your fertile window here."
                )
            } else {
                Chart(data) { item in
                    BarMark(
                        x: .value("Day", "Day \(item.cycleDay)"),
                        y: .value("Level", item.level)
                    )
                    .foregroundStyle(item.color)
                    .cornerRadius(2)
                }
                .frame(height: 160)
                .chartYScale(domain: 0...4)
                .chartYAxis {
                    AxisMarks(values: [1, 2, 3, 4]) { value in
                        AxisValueLabel {
                            if let v = value.as(Int.self) {
                                Text(mucusLevelLabel(v))
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Placeholder card
    private func placeholderCard(icon: String, message: String) -> some View {
        HStack(spacing: DS.Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(DS.Color.secondaryText)
                .frame(width: DS.Spacing.lg)
            Text(message)
                .font(DS.Font.caption)
                .foregroundColor(DS.Color.secondaryText)
        }
        .padding(DS.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DS.Color.cardBackground)
        .cornerRadius(DS.Radius.chip)
    }

    // MARK: - Data models
    private struct PhaseFrequency {
        let phase: Event.EventType
        let phaseName: String
        let count: Int
        let color: Color
    }

    private struct CycleLength: Identifiable {
        let id = UUID()
        let label: String
        let days: Int
    }

    private struct FertilitySegment: Identifiable {
        let id = UUID()
        let label: String
        let days: Int
        let color: Color
    }

    private struct MucusPoint: Identifiable {
        let id = UUID()
        let cycleDay: Int
        let level: Int
        let color: Color
    }

    // MARK: - Data helpers
    private var tagFrequencyData: [PhaseFrequency] {
        Event.EventType.allCases.map { phase in
            let count = archivedDataStore.archivedBlocks.flatMap { block in
                block.groupedEvents.filter { $0.eventType == phase }.flatMap { $0.events }
            }.reduce(0) { total, event in
                let tags = event.tags.split(separator: ",").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                return total + tags.count
            }
            return PhaseFrequency(phase: phase, phaseName: "Phase \(phase.phaseNumber)", count: count, color: phase.phaseColor)
        }
    }

    private func topTags(for phase: Event.EventType) -> [(tag: String, count: Int)] {
        var freq: [String: Int] = [:]
        for block in archivedDataStore.archivedBlocks {
            for p in block.groupedEvents where p.eventType == phase {
                for event in p.events {
                    event.tags.split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                        .forEach { freq[$0, default: 0] += 1 }
                }
            }
        }
        return freq.sorted { $0.value > $1.value }.prefix(3).map { (tag: $0.key, count: $0.value) }
    }

    private var cycleLengthData: [CycleLength] {
        let sorted = archivedDataStore.archivedBlocks.sorted { $0.date < $1.date }
        return sorted.enumerated().compactMap { (index, block) in
            let allDates = block.groupedEvents.flatMap { $0.events }.map { $0.date }
            guard let first = allDates.min(), let last = allDates.max() else { return nil }
            let days = Calendar.current.dateComponents([.day], from: first, to: last).day.map { $0 + 1 } ?? 0
            guard days > 0 else { return nil }
            return CycleLength(label: "Cycle \(index + 1)", days: days)
        }
    }

    private var fertilitySegments: [FertilitySegment] {
        let grouped = Dictionary(grouping: myEvents.events) { $0.eventType }
        return Event.EventType.allCases.compactMap { phase in
            guard let events = grouped[phase], !events.isEmpty else { return nil }
            let label: String
            switch phase {
            case .menstrual:  label = "Menstrual"
            case .follicular: label = "Follicular"
            case .ovulation:  label = "Fertile Window"
            case .luteal:     label = "Luteal"
            }
            return FertilitySegment(label: label, days: events.count, color: phase.phaseColor)
        }
    }

    private var cervicalMucusData: [MucusPoint] {
        let sorted = myEvents.events.sorted { $0.date < $1.date }
        guard let firstDate = sorted.first?.date else { return [] }
        var points: [MucusPoint] = []
        for event in sorted {
            let day = Calendar.current.dateComponents([.day], from: firstDate, to: event.date).day.map { $0 + 1 } ?? 1
            let tags = event.tags.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            for tag in tags {
                let lower = tag.lowercased()
                if lower.contains("cervical mucus:") || lower.hasPrefix("cervical mucus") {
                    let value = tag.split(separator: ":").last.map { String($0).trimmingCharacters(in: .whitespaces) } ?? ""
                    let level = mucusLevel(value)
                    if level > 0 {
                        points.append(MucusPoint(cycleDay: day, level: level, color: mucusColor(level)))
                    }
                }
            }
        }
        return points
    }

    private func mucusLevel(_ value: String) -> Int {
        switch value.lowercased() {
        case "dry":        return 1
        case "sticky":     return 2
        case "creamy":     return 3
        case "egg white":  return 4
        default:           return 0
        }
    }

    private func mucusColor(_ level: Int) -> Color {
        switch level {
        case 1: return Color.gray.opacity(0.5)
        case 2: return DS.Color.phase3.opacity(0.6)
        case 3: return DS.Color.phase3
        case 4: return DS.Color.phase2
        default: return .clear
        }
    }

    private func mucusLevelLabel(_ level: Int) -> String {
        switch level {
        case 1: return "Dry"
        case 2: return "Sticky"
        case 3: return "Creamy"
        case 4: return "Egg White"
        default: return ""
        }
    }
}

#Preview {
    InsightsView()
        .environmentObject(ArchivedDataStore())
        .environmentObject(EventStore(preview: true))
}
