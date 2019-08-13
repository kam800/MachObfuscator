//
//  Mach+Loading_MachoMac10_14_Tests.swift
//  MachObfuscatorTests
//

import XCTest

class Mach_Loading_MachoMac10_14_Tests: XCTestCase {
    let sut = try! Image.load(url: URL.machoMac10_14Executable)

    func test_shouldDetectCorrectPlatform() {
        XCTAssertEqual(sut.url, URL.machoMac10_14Executable)
        guard case let .mach(mach) = sut.contents else {
            XCTFail("Unexpected contents")
            return
        }
        XCTAssertEqual(mach.data, try! Data(contentsOf: URL.machoMac10_14Executable))
        XCTAssertEqual(mach.type, .executable)
        XCTAssertEqual(mach.platform, .macos)
    }
}
