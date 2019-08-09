import Foundation
import XCTest

class NibArchive_Loading_Tests: XCTestCase {
    func test_canLoad_shouldBeTrueForIosNib() {
        XCTAssert(NibArchive.canLoad(from: URL.iosNib))
    }

    func test_canLoad_shouldBeFalseForMacNib() {
        XCTAssertFalse(NibArchive.canLoad(from: URL.macNib))
    }

    func test_load_shouldNotThrowForIosNib() {
        XCTAssertNoThrow(NibArchive.load(from: URL.iosNib))
    }
}
