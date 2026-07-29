import XCTest
@testable import Denly

final class EnamelMotionTests: XCTestCase {

    func test_givenStampMotion_whenReadingPeakScale_thenItIs106Percent() {
        XCTAssertEqual(EnamelMotion.stampPeakScale, 1.06, accuracy: 0.001)
    }

    func test_givenReduceMotion_whenAskingForNumberRoll_thenNil() {
        XCTAssertNil(EnamelMotion.numberRoll(reduceMotion: true))
        XCTAssertNotNil(EnamelMotion.numberRoll(reduceMotion: false))
    }

    func test_givenMetrics_whenReadingRadius_thenItIsTwentyEight() {
        XCTAssertEqual(EnamelMetrics.radius, 28)
        XCTAssertEqual(EnamelMetrics.stroke, 2)
    }

    func test_givenPalette_whenCountingTokens_thenSevenEntries() {
        XCTAssertEqual(EnamelPalette.inventory.count, 7)
    }

    func test_givenRoutineSlot_whenSorting_thenMorningFirst() {
        XCTAssertLessThan(RoutineSlot.morning.sortOrder, RoutineSlot.evening.sortOrder)
    }
}
