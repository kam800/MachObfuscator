import XCTest

class ObjectSymbols_blacklist_Tests: XCTestCase {
    var testSymbolsLoader: ObfuscationSymbolsTestSourceSymbolsLoader! = ObfuscationSymbolsTestSourceSymbolsLoader()
    var sut: ObjectSymbols!

    override func setUp() {
        super.setUp()

        testSymbolsLoader["/tmp/githubLibrary"] = ObjectSymbols(
            selectors: ["githubSelector"],
            classNames: ["githubClass"]
        )

        testSymbolsLoader["/tmp/bitbucketLibrary"] = ObjectSymbols(
            selectors: ["bitbucketSelector"],
            classNames: ["bitbucketClass"]
        )

        sut = ObjectSymbols.blacklist(skippedSymbolsSources: ["/tmp/githubLibrary".asURL,
                                                              "/tmp/bitbucketLibrary".asURL],
                                      sourceSymbolsLoader: testSymbolsLoader)
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    func test_classNames_shouldContainClassNamesFromSkippedSymbolsSources() {
        XCTAssert(sut.classNames.contains("githubClass"))
        XCTAssert(sut.classNames.contains("bitbucketClass"))
    }

    func test_slectors_shouldContainSelectorsFromSkippedSymbolsSources() {
        XCTAssert(sut.selectors.contains("githubSelector"))
        XCTAssert(sut.selectors.contains("bitbucketSelector"))
    }
}
