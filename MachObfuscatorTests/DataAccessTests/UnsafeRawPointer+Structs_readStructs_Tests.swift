import XCTest

class UnsafeRawPointer_Structs_readStructs_Tests: XCTestCase {
    private struct Sample {
        var b1: UInt16
        var b2: UInt16
    }

    let bytes: [UInt8] = [0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF]

    func test_shouldReadSampleStructs() {
        // Given
        bytes.withUnsafeBytes { bytes in
            var cursor = bytes.baseAddress!

            // When
            let samples: [Sample] = cursor.readStructs(count: 3)

            // Then
            XCTAssertEqual(samples.count, 3)
            XCTAssertEqual(samples[0].b1, 0xF2F1)
            XCTAssertEqual(samples[0].b2, 0xF4F3)
            XCTAssertEqual(samples[1].b1, 0xF6F5)
            XCTAssertEqual(samples[1].b2, 0xF8F7)
            XCTAssertEqual(samples[2].b1, 0xFAF9)
            XCTAssertEqual(samples[2].b2, 0xFCFB)
            XCTAssertEqual(bytes.baseAddress!.distance(to: cursor), 12)
        }
    }
}
