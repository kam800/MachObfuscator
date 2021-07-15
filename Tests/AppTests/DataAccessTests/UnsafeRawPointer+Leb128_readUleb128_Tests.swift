@testable import App
import XCTest

class UnsafeRawPointer_Leb128_readUleb128_Tests: XCTestCase {
    func template(bytes: [UInt8], expectedNumber: UInt64, expectedPointerOffset: Int, file: StaticString = #file, line: UInt = #line) {
        let (number, offset) = bytes.withUnsafeBytes { bytes -> (UInt64, Int) in
            var cursor = bytes.baseAddress!
            let number = cursor.readUleb128()
            let offset = bytes.baseAddress!.distance(to: cursor)
            return (number, offset)
        }

        XCTAssertEqual(number, expectedNumber, "Unexpected number", file: file, line: line)
        XCTAssertEqual(offset, expectedPointerOffset, "Unexpected offset", file: file, line: line)
    }

    func test_oneByte() {
        template(bytes: [0b0011_0010, 0b0110_0110],
                 expectedNumber: 0b0011_0010,
                 expectedPointerOffset: 1)
    }

    func test_twoBytes() {
        template(bytes: [0b1000_0000, 0b0100_1110, 0b0100_0010],
                 expectedNumber: 0b010_0111_0000_0000,
                 expectedPointerOffset: 2)
    }

    func test_threeBytes() {
        template(bytes: [0b1110_0101, 0b1000_1110, 0b0010_0110, 0b0001_0010],
                 expectedNumber: 0b00_1001_1000_0111_0110_0101,
                 expectedPointerOffset: 3)
    }

    func test_nineBytes() {
        template(bytes: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F],
                 expectedNumber: 0x7FFF_FFFF_FFFF_FFFF,
                 expectedPointerOffset: 9)
    }

    func test_tenBytes() {
        template(bytes: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x01],
                 expectedNumber: 0xFFFF_FFFF_FFFF_FFFF,
                 expectedPointerOffset: 10)
        template(bytes: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00],
                 expectedNumber: 0x7FFF_FFFF_FFFF_FFFF,
                 expectedPointerOffset: 10)
    }

    func test_tenBytes_shouldIgnoreOverflow() {
        template(bytes: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F],
                 expectedNumber: 0xFFFF_FFFF_FFFF_FFFF,
                 expectedPointerOffset: 10)
    }
}
