import XCTest

class TextFileSymbolListLoader_load_Tests: XCTestCase {
    var sut: TextFileSymbolListLoader!

    override func setUp() {
        super.setUp()

        sut = TextFileSymbolListLoader()
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    func test_load_shouldTryToReadTheFileStringContents() throws {
        // Given
        let exp = expectation(description: "stringWithContentsOf expected")
        var capturedUrl: URL!
        // When
        _ = try sut.load(fromTextFile: .sample, stringWithContentsOf: { url in
            capturedUrl = url
            exp.fulfill()
            return "contents"
        })

        // Then
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssertEqual(URL.sample, capturedUrl)
    }

    func test_load_shouldReturnOnlyPotentialClassNames() throws {
        // When
        let result = try sut.load(fromTextFile: .sample, stringWithContentsOf: { _ in
            """
                   Class_1_żółć_ok
               Class  WithSpace
            Cl!ass
            Cl@ass
            Cl#ass
            Cl$ass
            Cl%ass
            Cl^ass
            Cl&ass
            Cl*ass
            Cl(ass
            Cl)ass
            Cl:ass
            Cl?ass
            """
        })

        // Then
        XCTAssertEqual(result.classNames, ["Class_1_żółć_ok"])
    }

    func test_load_shouldReturnOnlyPotentialSelectors() throws {
        // When
        let result = try sut.load(fromTextFile: .sample, stringWithContentsOf: { _ in
            """
                    getter
                   selectors_are_great:lol:
               selector  withSpace
            se!lector
            se@lector
            se#lector
            se$lector
            se%lector
            se^lector
            se&lector
            se*lector
            se(lector
            se)lector
            se?lector
            """
        })

        // Then
        XCTAssertEqual(result.selectors, ["getter", "selectors_are_great:lol:"])
    }
}

private extension URL {
    static let sample = URL(fileURLWithPath: "/tmp/sample.txt")
}
