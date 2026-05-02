// RhythmXTests/InsightsViewModelTests.swift
import XCTest
@testable import RhythmX

@MainActor
final class InsightsViewModelTests: XCTestCase {

    // Fixed anchor so day-offset arithmetic is deterministic
    private let anchor = Calendar.current.date(
        from: DateComponents(year: 2024, month: 1, day: 1)
    )!

    private func event(
        type: Event.EventType,
        dayOffset: Int,
        tags: String = ""
    ) -> Event {
        let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: anchor)!
        return Event(eventType: type, date: date, note: "", tags: tags)
    }

    private func block(events: [Event]) -> ArchivedDataBlock {
        let grouped = Dictionary(grouping: events, by: { $0.eventType })
            .map { ArchivedDataBlock.PhaseEvents(eventType: $0.key, events: $0.value) }
        return ArchivedDataBlock(date: anchor, groupedEvents: grouped)
    }

    // MARK: - dailyTagData

    func testDailyTagDataEmptyWhenNoEvents() {
        let vm = InsightsViewModel(events: [], archivedBlocks: [], appSettings: AppSettings())
        XCTAssertTrue(vm.dailyTagData.isEmpty)
    }

    func testDailyTagDataExcludesEventsWithNoTags() {
        let events = [
            event(type: .menstrual, dayOffset: 0, tags: ""),
            event(type: .follicular, dayOffset: 1, tags: "Symptom:Cramps"),
        ]
        let vm = InsightsViewModel(events: events, archivedBlocks: [], appSettings: AppSettings())
        XCTAssertEqual(vm.dailyTagData.count, 1)
        XCTAssertEqual(vm.dailyTagData[0].cycleDay, 2)
        XCTAssertEqual(vm.dailyTagData[0].count, 1)
    }

    func testDailyTagDataCountsCommaSeparatedTagsPerDay() {
        let events = [
            event(type: .menstrual, dayOffset: 0, tags: "Symptom:Cramps, Mood:Tired"),
            event(type: .follicular, dayOffset: 2, tags: "Exercise:Walk"),
        ]
        let vm = InsightsViewModel(events: events, archivedBlocks: [], appSettings: AppSettings())
        let data = vm.dailyTagData.sorted { $0.cycleDay < $1.cycleDay }
        XCTAssertEqual(data.count, 2)
        XCTAssertEqual(data[0].cycleDay, 1)
        XCTAssertEqual(data[0].count, 2)
        XCTAssertEqual(data[1].cycleDay, 3)
        XCTAssertEqual(data[1].count, 1)
    }

    // MARK: - phaseSpans

    func testPhaseSpansEmptyWhenNoEvents() {
        let vm = InsightsViewModel(events: [], archivedBlocks: [], appSettings: AppSettings())
        XCTAssertTrue(vm.phaseSpans.isEmpty)
    }

    func testPhaseSpansCorrectDayRange() {
        // menstrual at offsets 0,1,2 → startDay=1, endDay=4 (last offset 2 → endDay_local=3, +1=4)
        // follicular at offsets 3,4  → startDay=4, endDay=6 (last offset 4 → endDay_local=5, +1=6)
        let events = [
            event(type: .menstrual,  dayOffset: 0),
            event(type: .menstrual,  dayOffset: 1),
            event(type: .menstrual,  dayOffset: 2),
            event(type: .follicular, dayOffset: 3),
            event(type: .follicular, dayOffset: 4),
        ]
        let vm = InsightsViewModel(events: events, archivedBlocks: [], appSettings: AppSettings())
        let spans = vm.phaseSpans
        let m = spans.first { $0.label == "Menstrual" }!
        let f = spans.first { $0.label == "Follicular" }!
        XCTAssertEqual(m.startDay, 1)
        XCTAssertEqual(m.endDay,   4)
        XCTAssertEqual(f.startDay, 4)
        XCTAssertEqual(f.endDay,   6)
    }
}
