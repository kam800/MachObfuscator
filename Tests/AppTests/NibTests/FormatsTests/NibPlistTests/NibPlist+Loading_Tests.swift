@testable import App
import Foundation
import XCTest

class NibPlist_Loading_Tests: XCTestCase {
    func test_canLoad_shouldBeTrueForMacNib() {
        XCTAssert(NibPlist.canLoad(from: URL.macNib))
    }

    func test_canLoad_shouldBeFalseForIosNib() {
        XCTAssertFalse(NibPlist.canLoad(from: URL.iosNib))
    }

    func test_load_shouldNotThrowForMacNib() {
        XCTAssertNoThrow(NibPlist.load(from: URL.macNib))
    }
}
