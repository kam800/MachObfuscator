import XCTest

class ObjectSymbols_Blacklisting_blackListWithSkippedSymbolsSources_Tests: XCTestCase {
    var testSourceSymbolsLoader: ObjectSymbolsLoaderMock! = ObjectSymbolsLoaderMock()
    var sut: ObjectSymbols!

    override func setUp() {
        super.setUp()

        testSourceSymbolsLoader["/tmp/githubLibrary"] = ObjectSymbols(
            selectors: ["githubSelector"],
            classNames: ["githubClass"]
        )

        testSourceSymbolsLoader["/tmp/bitbucketLibrary"] = ObjectSymbols(
            selectors: ["bitbucketSelector"],
            classNames: ["bitbucketClass"]
        )

        sut = ObjectSymbols.blacklist(skippedSymbolsSources: ["/tmp/githubLibrary".asURL,
                                                              "/tmp/bitbucketLibrary".asURL],
                                      sourceSymbolsLoader: testSourceSymbolsLoader)
    }

    override func tearDown() {
        sut = nil
        testSourceSymbolsLoader = nil

        super.tearDown()
    }

    func test_classNames_shouldContainClassNamesFromSkippedSymbolsSources() {
        XCTAssert(sut.classNames.contains("githubClass"))
        XCTAssert(sut.classNames.contains("bitbucketClass"))
    }

    func test_selectors_shouldContainSelectorsFromSkippedSymbolsSources() {
        XCTAssert(sut.selectors.contains("githubSelector"))
        XCTAssert(sut.selectors.contains("bitbucketSelector"))
    }
}
