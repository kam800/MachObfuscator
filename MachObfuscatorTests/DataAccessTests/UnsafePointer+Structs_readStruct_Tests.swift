import XCTest

class UnsafePointer_Structs_readStruct_Tests: XCTestCase {

    private struct Sample {
        var b1: UInt16
        var b2: UInt16
    }

    let bytes: [UInt8] = [ 0xab, 0xcd, 0xef, 0x02, 0x03  ]

    func test_shouldReadSampleStruct() {
        // Given
        bytes.withUnsafeBufferPointer { ptr in
            var cursor = ptr.baseAddress!

            // When
            let sample: Sample = cursor.readStruct()

            // Then
            XCTAssertEqual(sample.b1, 0xcdab)
            XCTAssertEqual(sample.b2, 0x02ef)
            XCTAssertEqual(ptr.baseAddress!.distance(to: cursor), 4)
        }
    }
}
