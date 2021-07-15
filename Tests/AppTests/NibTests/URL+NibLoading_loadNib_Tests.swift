@testable import App
import XCTest

class URL_NibLoading_loadNib_Tests: XCTestCase {
    func test_shouldLoadIosNib() {
        // When
        let nib = URL.iosNib.loadNib()

        // Then
        XCTAssertEqual(nib.classNames.count, 2)
    }

    func test_shouldLoadMacNib() {
        // When
        let nib = URL.macNib.loadNib()

        // Then
        XCTAssertEqual(nib.classNames.count, 4)
    }
}
