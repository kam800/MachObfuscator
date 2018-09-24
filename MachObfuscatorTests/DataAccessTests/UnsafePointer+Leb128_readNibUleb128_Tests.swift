import XCTest

class UnsafePointer_Leb128_readNibUleb128_Tests: XCTestCase {

    func template(bytes: [UInt8], expectedNumber: UInt64, expectedPointerOffset: Int, file: StaticString = #file, line: UInt = #line) {
        let (number, offset) = bytes.withUnsafeBufferPointer { ptr -> (UInt64, Int) in
            var cursor = ptr.baseAddress!
            let number = cursor.readNibUleb128()
            let offset = ptr.baseAddress!.distance(to: cursor)
            return (number, offset)
        }

        XCTAssertEqual(number, expectedNumber, "Unexpected number", file: file, line: line)
        XCTAssertEqual(offset, expectedPointerOffset, "Unexpected offset", file: file, line: line)
    }

    func test_oneByte() {
        template(bytes: [ 0b1011_0010, 0b0110_0110 ],
                 expectedNumber: 0b0_011_0010,
                 expectedPointerOffset: 1)
    }

    func test_twoBytes() {
        template(bytes: [ 0b0000_0000, 0b1100_1110, 0b0100_0010 ],
                 expectedNumber: 0b0_100_1110_000_0000,
                 expectedPointerOffset: 2)
    }

    func test_threeBytes() {
        template(bytes: [ 0b0110_0101, 0b0000_1110, 0b1010_0110, 0b0001_0010 ],
                 expectedNumber: 0b0_010_0110_000_1110_110_0101,
                 expectedPointerOffset: 3)
    }

    func test_nineBytes() {
        template(bytes: [ 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0xff ],
                 expectedNumber: 0x7fffffffffffffff,
                 expectedPointerOffset: 9)
    }

    func test_tenBytes() {
        template(bytes: [ 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x81 ],
                 expectedNumber: 0xffffffffffffffff,
                 expectedPointerOffset: 10)
        template(bytes: [ 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x80 ],
                 expectedNumber: 0x7fffffffffffffff,
                 expectedPointerOffset: 10)
    }

    func test_tenBytes_shouldIgnoreOverflow() {
        template(bytes: [ 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0xff ],
                 expectedNumber: 0xffffffffffffffff,
                 expectedPointerOffset: 10)
    }
}
