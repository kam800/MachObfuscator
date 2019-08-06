import XCTest

class Range_Sugar_Tests: XCTestCase {
    func test_initWithOffsetAndCount_shouldReturnCalculatedRange() {
        // When
        let range = Range(offset: 13, count: 29)

        // Then
        XCTAssertEqual(range, 13 ..< 42)
    }

    func test_intRange_shouldConvertNonIntRange() {
        // Given
        let int8Range: Range<Int8> = (3 as Int8) ..< (9 as Int8)
        // When
        let intRange: Range<Int> = int8Range.intRange

        // Then
        XCTAssertEqual(intRange, 3 ..< 9)
    }
}
