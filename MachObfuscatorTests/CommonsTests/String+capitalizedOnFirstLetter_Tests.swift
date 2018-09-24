import XCTest

class String_capitalizedOnFirstLetter_Tests: XCTestCase {
    func test_shouldCapitalizeFirstLetterInLongSentence() {
        XCTAssertEqual("feed my face".capitalizedOnFirstLetter,
                       "Feed my face")
    }

    func test_shouldNotChangeAlreadyCapitalizedString() {
        let str = "Poland"
        XCTAssertEqual(str.capitalizedOnFirstLetter, str)
    }

    func test_shouldCapitalizeOneLetterString() {
        XCTAssertEqual("a".capitalizedOnFirstLetter, "A")
    }

    func test_shouldNotChangeEmptyString() {
        XCTAssertEqual("".capitalizedOnFirstLetter, "")
    }
}
