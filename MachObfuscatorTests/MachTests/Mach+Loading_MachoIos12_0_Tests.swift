//
//  Mach+Loading_MachoIos12_0_Tests.swift
//  MachObfuscatorTests
//

import XCTest

class Mach_Loading_MachoIos12_0_Tests: XCTestCase {
    let sut = try! Image.load(url: URL.machoIos12_0Executable)

    func test_shouldDetectCorrectPlatform() {
        XCTAssertEqual(sut.url, URL.machoIos12_0Executable)
        guard case let .mach(mach) = sut.contents else {
            XCTFail("Unexpected contents")
            return
        }
        XCTAssertEqual(mach.data, try! Data(contentsOf: URL.machoIos12_0Executable))
        XCTAssertEqual(mach.type, .executable)
        XCTAssertEqual(mach.platform, .ios)
    }
}
