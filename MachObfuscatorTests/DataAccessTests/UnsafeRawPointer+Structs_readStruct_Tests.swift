import XCTest

class UnsafeRawPointer_Structs_readStruct_Tests: XCTestCase {
    private struct Sample {
        var b1: UInt16
        var b2: UInt16
    }

    let bytes: [UInt8] = [0xAB, 0xCD, 0xEF, 0x02, 0x03]

    func test_shouldReadSampleStruct() {
        // Given
        bytes.withUnsafeBytes { bytes in
            var cursor = bytes.baseAddress!

            // When
            let sample: Sample = cursor.readStruct()

            // Then
            XCTAssertEqual(sample.b1, 0xCDAB)
            XCTAssertEqual(sample.b2, 0x02EF)
            XCTAssertEqual(bytes.baseAddress!.distance(to: cursor), 4)
        }
    }
}
