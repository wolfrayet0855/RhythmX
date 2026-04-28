import XCTest
@testable import RhythmX

@MainActor
final class EventStoreTests: XCTestCase {

    var store: EventStore!

    override func setUp() {
        super.setUp()
        store = EventStore(preview: true)
    }

    func testAddEventAppendsToEvents() {
        let event = Event(eventType: .menstrual, date: Date(), note: "test")
        store.add(event)
        XCTAssertEqual(store.events.count, 1)
        XCTAssertEqual(store.events.first?.id, event.id)
    }

    func testDeleteEventRemovesFromEvents() {
        let event = Event(eventType: .follicular, date: Date(), note: "test")
        store.add(event)
        store.delete(event)
        XCTAssertTrue(store.events.isEmpty)
    }

    func testUpdateEventReplacesById() {
        let original = Event(eventType: .luteal, date: Date(), note: "original")
        store.add(original)
        var updated = original
        updated.note = "updated"
        store.update(updated)
        XCTAssertEqual(store.events.first?.note, "updated")
    }

    func testGenerateCycleEventsProducesCorrectCount() {
        store.generateCycleEvents(startDate: Date(), cycleLength: 28)
        XCTAssertEqual(store.events.count, 28)
    }

    func testGenerateCycleEventsCoversFourPhases() {
        store.generateCycleEvents(startDate: Date(), cycleLength: 28)
        let types = Set(store.events.map { $0.eventType })
        XCTAssertEqual(types, [.menstrual, .follicular, .ovulation, .luteal])
    }

    func testClearAllEventsEmptiesStore() {
        store.generateCycleEvents(startDate: Date(), cycleLength: 28)
        store.clearAllEvents()
        XCTAssertTrue(store.events.isEmpty)
    }

    func testPreviewModeDoesNotPersist() {
        let event = Event(eventType: .ovulation, date: Date(), note: "preview")
        store.add(event)
        let freshStore = EventStore(preview: true)
        XCTAssertTrue(freshStore.events.isEmpty)
    }
}
