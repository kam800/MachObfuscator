@testable import App
import Foundation
import XCTest

class Data_nullify_Tests: XCTestCase {
    func test_shouldSetZerosInRange() {
        // Given
        var sut = Data(repeating: 0xAB, count: 20)

        // When
        sut.nullify(range: 8 ..< 15)

        // Then
        let expectedData = Data(
            [UInt8](repeating: 0xAB, count: 8)
                + [UInt8](repeating: 0x00, count: 7)
                + [UInt8](repeating: 0xAB, count: 5)
        )
        XCTAssertEqual(sut, expectedData)
    }
}
