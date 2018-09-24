import XCTest

class UnsafePointer_CString_Tests: XCTestCase {

    func template(bytes: [UInt8], expectedStringBytes: [UInt8], expectedPointerOffset: Int, file: StaticString = #file, line: UInt = #line) {
        let (number, offset) = bytes.withUnsafeBufferPointer { ptr -> ([UInt8], Int) in
            var baseAddress = ptr.baseAddress!
            let stringBytes = baseAddress.readStringBytes()
            let offset = ptr.baseAddress!.distance(to: baseAddress)
            return (stringBytes, offset)
        }

        XCTAssertEqual(number, expectedStringBytes, "Unexpected string bytes", file: file, line: line)
        XCTAssertEqual(offset, expectedPointerOffset, "Unexpected offset", file: file, line: line)
    }

    func test_zeroBytes() {
        template(bytes: [ 0, 1, 2, 3 ],
                 expectedStringBytes: [],
                 expectedPointerOffset: 1)
    }

    func test_oneBytes() {
        template(bytes: [ 1, 0, 2, 3 ],
                 expectedStringBytes: [ 1 ],
                 expectedPointerOffset: 2)
    }

    func test_twoBytes() {
        template(bytes: [ 1, 2, 0, 3 ],
                 expectedStringBytes: [ 1, 2 ],
                 expectedPointerOffset: 3)
    }

    func test_threeBytes() {
        template(bytes: [ 1, 2, 3, 0, 4, 5, 0 ],
                 expectedStringBytes: [ 1, 2, 3 ],
                 expectedPointerOffset: 4)
    }
}
