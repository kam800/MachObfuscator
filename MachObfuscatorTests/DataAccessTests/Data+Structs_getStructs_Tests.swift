import XCTest

class Data_Structs_getStructs_Tests: XCTestCase {

    private struct Sample {
        var b1: UInt16
        var b2: UInt16
    }

    func test_shouldReadSampleStructs() {
        // Given
        let data = Data( [ 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff ])

        // When
        let samples: [Sample] = data.getStructs(atOffset: 2, count: 3)

        // Then
        XCTAssertEqual(samples.count, 3)
        XCTAssertEqual(samples[0].b1, 0xf4f3)
        XCTAssertEqual(samples[0].b2, 0xf6f5)
        XCTAssertEqual(samples[1].b1, 0xf8f7)
        XCTAssertEqual(samples[1].b2, 0xfaf9)
        XCTAssertEqual(samples[2].b1, 0xfcfb)
        XCTAssertEqual(samples[2].b2, 0xfefd)
    }
}
