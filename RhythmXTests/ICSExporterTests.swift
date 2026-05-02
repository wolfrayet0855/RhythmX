import XCTest
@testable import RhythmX

final class ICSExporterTests: XCTestCase {

    private func makeEvents(
        _ type: Event.EventType,
        startOffset: Int,
        count: Int,
        base: Date
    ) -> [Event] {
        (0..<count).map { i in
            Event(
                eventType: type,
                date: Calendar.current.date(byAdding: .day, value: startOffset + i, to: base)!,
                note: ""
            )
        }
    }

    func testEmptyEventsProducesValidCalendar() {
        let ics = String(data: ICSExporter.export(events: [], sharerName: "Alice"), encoding: .utf8)!
        XCTAssertTrue(ics.contains("BEGIN:VCALENDAR"))
        XCTAssertTrue(ics.contains("END:VCALENDAR"))
        XCTAssertFalse(ics.contains("BEGIN:VEVENT"))
    }

    func testOnePhaseProducesOneVEvent() {
        let base = Calendar.current.startOfDay(for: Date())
        let events = makeEvents(.menstrual, startOffset: 0, count: 5, base: base)
        let ics = String(data: ICSExporter.export(events: events, sharerName: "Alice"), encoding: .utf8)!
        XCTAssertEqual(ics.components(separatedBy: "BEGIN:VEVENT").count - 1, 1)
    }

    func testFourPhasesProduceFourVEvents() {
        let base = Calendar.current.startOfDay(for: Date())
        let events =
            makeEvents(.menstrual,  startOffset: 0,  count: 5,  base: base) +
            makeEvents(.follicular, startOffset: 5,  count: 8,  base: base) +
            makeEvents(.ovulation,  startOffset: 13, count: 3,  base: base) +
            makeEvents(.luteal,     startOffset: 16, count: 12, base: base)
        let ics = String(data: ICSExporter.export(events: events, sharerName: "Alice"), encoding: .utf8)!
        XCTAssertEqual(ics.components(separatedBy: "BEGIN:VEVENT").count - 1, 4)
    }

    func testSummaryIncludesSharerName() {
        let base = Calendar.current.startOfDay(for: Date())
        let events = makeEvents(.menstrual, startOffset: 0, count: 5, base: base)
        let ics = String(data: ICSExporter.export(events: events, sharerName: "Alice"), encoding: .utf8)!
        XCTAssertTrue(ics.contains("SUMMARY:Alice's Menstrual Phase"))
    }

    func testSummaryWithEmptyNameOmitsApostrophe() {
        let base = Calendar.current.startOfDay(for: Date())
        let events = makeEvents(.menstrual, startOffset: 0, count: 5, base: base)
        let ics = String(data: ICSExporter.export(events: events, sharerName: ""), encoding: .utf8)!
        XCTAssertTrue(ics.contains("SUMMARY:Menstrual Phase"))
        XCTAssertFalse(ics.contains("'s"))
    }

    func testDtendIsOneDayAfterLastEventDate() {
        // 5 events: days 0–4. Last date = base+4. DTEND must be base+5 (exclusive per RFC 5545).
        let base = Calendar.current.startOfDay(for: Date())
        let events = makeEvents(.menstrual, startOffset: 0, count: 5, base: base)
        let ics = String(data: ICSExporter.export(events: events, sharerName: ""), encoding: .utf8)!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = TimeZone.current
        let expectedDtend = formatter.string(from: Calendar.current.date(byAdding: .day, value: 5, to: base)!)
        XCTAssertTrue(ics.contains("DTEND;VALUE=DATE:\(expectedDtend)"))
    }

    func testOutputUsesCRLFLineEndings() {
        let ics = String(data: ICSExporter.export(events: [], sharerName: ""), encoding: .utf8)!
        XCTAssertTrue(ics.contains("\r\n"))
        XCTAssertTrue(ics.hasSuffix("\r\n"))
    }
}
