import XCTest

class Data_Magic_Tests: XCTestCase {

    func test_magicFromData() {
        // Given
        let data = Data(bytes: [ 0xca, 0xfe, 0xba, 0xbe, 0x01, 0x02, 0x03, 0x04 ])

        // Expect
        XCTAssertEqual(data.magic, 0xbebafeca)
    }
}
