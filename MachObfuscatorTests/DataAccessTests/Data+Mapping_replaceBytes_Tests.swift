import XCTest

class Data_Mapping_replaceBytes_Tests: XCTestCase {
    func test_shouldReplaceBytes() {
        // Given
        var data = Data([0x01, 0x02, 0x03, 0x04, 0x05, 0x06])

        // When
        data.replaceBytes(inRange: 2 ..< 5, withBytes: [0x10, 0x11, 0x12])

        // Then
        XCTAssertEqual(data, Data([0x01, 0x02, 0x10, 0x11, 0x12, 0x06]))
    }
}
