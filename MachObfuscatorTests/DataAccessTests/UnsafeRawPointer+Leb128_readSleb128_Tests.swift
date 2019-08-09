import XCTest

class UnsafeRawPointer_Leb128_readSleb128_Tests: XCTestCase {
    func template(bytes: [UInt8], expectedNumber: Int64, expectedPointerOffset: Int, file: StaticString = #file, line: UInt = #line) {
        let (number, offset) = bytes.withUnsafeBytes { bytes -> (Int64, Int) in
            var cursor = bytes.baseAddress!
            let number = cursor.readSleb128()
            let offset = bytes.baseAddress!.distance(to: cursor)
            return (number, offset)
        }

        XCTAssertEqual(number, expectedNumber, "Unexpected number", file: file, line: line)
        XCTAssertEqual(offset, expectedPointerOffset, "Unexpected offset", file: file, line: line)
    }

    func test_oneByte_positive() {
        template(bytes: [0b0011_0010, 0b0101_0101],
                 expectedNumber: 0b0011_0010,
                 expectedPointerOffset: 1)
    }

    func test_oneByte_negative() {
        template(bytes: [0b0101_0110, 0b0101_0101],
                 expectedNumber: Int64(Int8(truncating: 0b1101_0110)),
                 expectedPointerOffset: 1)
    }

    func test_twoBytes_positive() {
        template(bytes: [0b1000_1100, 0b0010_1110],
                 expectedNumber: 0b01_0111_0000_1100,
                 expectedPointerOffset: 2)
    }

    func test_twoBytes_negative() {
        template(bytes: [0b1001_0011, 0b0101_0001],
                 expectedNumber: Int64(Int16(truncating: 0b1110_1000_1001_0011)),
                 expectedPointerOffset: 2)
    }

    func test_threeBytes_positive() {
        template(bytes: [0b1110_0101, 0b1000_1110, 0b0010_0110],
                 expectedNumber: 0b00_1001_1000_0111_0110_0101,
                 expectedPointerOffset: 3)
    }

    func test_threeBytes_negative() {
        template(bytes: [0b1110_0101, 0b1000_1110, 0b0110_0110],
                 expectedNumber: Int64(Int32(truncating: 0b1111_1111_1111_1001_1000_0111_0110_0101)),
                 expectedPointerOffset: 3)
    }

    func test_nineBytes_positive() {
        template(bytes: [0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x3F],
                 expectedNumber: 0x3FFF_FFFF_FFFF_FFFE,
                 expectedPointerOffset: 9)
    }

    func test_nineBytes_negative() {
        template(bytes: [0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F],
                 expectedNumber: -2,
                 expectedPointerOffset: 9)
    }

    func test_tenBytes_positive() {
        template(bytes: [0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00],
                 expectedNumber: 0x7FFF_FFFF_FFFF_FFFE,
                 expectedPointerOffset: 10)
    }

    func test_tenBytes_negative() {
        template(bytes: [0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F],
                 expectedNumber: -2,
                 expectedPointerOffset: 10)
    }

    func test_tenBytes_shouldIgnoreOverflow_positive() {
        template(bytes: [0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x3F],
                 expectedNumber: 0x7FFF_FFFF_FFFF_FFFE,
                 expectedPointerOffset: 10)
    }

    func test_tenBytes_shouldIgnoreOverflow_negative() {
        template(bytes: [0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x40],
                 expectedNumber: -2,
                 expectedPointerOffset: 10)
    }
}
