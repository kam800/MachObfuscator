@testable import App
import XCTest

class RecursiveSourceSymbolsLoader_loadFromSourcesURL_Tests: XCTestCase {
    var symbols: ObjectSymbols!

    override func setUp() {
        super.setUp()

        let sut = RecursiveSourceSymbolsLoader()
        symbols = sut.load(fromDirectory: URL.librarySourceCode)
    }

    override func tearDown() {
        symbols = nil

        super.tearDown()
    }

    func test_shouldParseSelectors() {
        let expectedMethods: Set<String> = [
            "publicMethod",
            "privateMethod",
        ]

        let expectedPropertyNames: Set<String> = [
            "publicProperty",
            "privateProperty",
        ]

        let expectedSelectors =
            expectedMethods.union(expectedPropertyNames)

        expectedSelectors.forEach {
            XCTAssert(symbols.selectors.contains($0), "Should contain: \($0)")
        }
        let unexpectedSelectors = symbols.selectors.subtracting(expectedSelectors)
        XCTAssertEqual(unexpectedSelectors, [], "Detected unexpected selectors")
    }

    func test_shouldParceClassNames() {
        let expectedClassNames: Set<String> = [
            "PublicClass",
            "PrivateClass",
        ]
        XCTAssertEqual(symbols.classNames.symmetricDifference(expectedClassNames), [])
    }
}
