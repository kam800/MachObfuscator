import XCTest

class Sequence_uniq_Tests: XCTestCase {

    let array: [UInt8] = [ 1, 2, 8, 2, 5, 0, 0, 2 ]

    func test_shouldMakeArrayElementsUnique() {
        // Expect
        XCTAssertEqual(array.uniq, [0, 1, 2, 5, 8])
    }
}
