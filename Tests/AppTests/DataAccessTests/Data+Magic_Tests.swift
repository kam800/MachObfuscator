@testable import App
import XCTest

class Data_Magic_Tests: XCTestCase {
    func test_magicFromData() {
        // Given
        let data = Data([0xCA, 0xFE, 0xBA, 0xBE, 0x01, 0x02, 0x03, 0x04])

        // Expect
        XCTAssertEqual(data.magic, 0xBEBA_FECA)
    }
}
