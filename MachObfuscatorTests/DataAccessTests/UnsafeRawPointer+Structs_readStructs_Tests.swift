import XCTest

class UnsafeRawPointer_Structs_readStructs_Tests: XCTestCase {

    private struct Sample {
        var b1: UInt16
        var b2: UInt16
    }

    let bytes: [UInt8] = [ 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff ]

    func test_shouldReadSampleStructs() {
        // Given
        bytes.withUnsafeBytes { bytes in
            var cursor = bytes.baseAddress!

            // When
            let samples: [Sample] = cursor.readStructs(count: 3)

            // Then
            XCTAssertEqual(samples.count, 3)
            XCTAssertEqual(samples[0].b1, 0xf2f1)
            XCTAssertEqual(samples[0].b2, 0xf4f3)
            XCTAssertEqual(samples[1].b1, 0xf6f5)
            XCTAssertEqual(samples[1].b2, 0xf8f7)
            XCTAssertEqual(samples[2].b1, 0xfaf9)
            XCTAssertEqual(samples[2].b2, 0xfcfb)
            XCTAssertEqual(bytes.baseAddress!.distance(to: cursor), 12)
        }
    }
}
