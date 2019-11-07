import XCTest

class ObjectSymbols_Blacklisting_Tests: XCTestCase {
    var testSourceSymbolsLoader: ObjectSymbolsLoaderMock! = ObjectSymbolsLoaderMock()
    var testSymbolsListLoader: ObjectSymbolsLoaderMock! = ObjectSymbolsLoaderMock()
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

        testSymbolsListLoader["/tmp/list1.txt"] = ObjectSymbols(
            selectors: ["list1Selector"],
            classNames: ["list1Class"]
        )

        testSymbolsListLoader["/tmp/list2.txt"] = ObjectSymbols(
            selectors: ["list2Selector"],
            classNames: ["list2Class"]
        )

        sut = ObjectSymbols.blacklist(skippedSymbolsSources: ["/tmp/githubLibrary".asURL,
                                                              "/tmp/bitbucketLibrary".asURL],
                                      skippedSymbolsLists: ["/tmp/list1.txt".asURL,
                                                            "/tmp/list2.txt".asURL],
                                      sourceSymbolsLoader: testSourceSymbolsLoader,
                                      symbolsListLoader: testSymbolsListLoader)
    }

    override func tearDown() {
        sut = nil
        testSymbolsListLoader = nil
        testSymbolsListLoader = nil

        super.tearDown()
    }

    func test_classNames_shouldContainClassNamesFromSkippedSymbolsSources() {
        XCTAssert(sut.classNames.contains("githubClass"))
        XCTAssert(sut.classNames.contains("bitbucketClass"))
    }

    func test_classNames_shouldContainClassNamesFromSkippedSymbolsLists() {
        XCTAssert(sut.classNames.contains("list1Class"))
        XCTAssert(sut.classNames.contains("list2Class"))
    }

    func test_selectors_shouldContainSelectorsFromSkippedSymbolsSources() {
        XCTAssert(sut.selectors.contains("githubSelector"))
        XCTAssert(sut.selectors.contains("bitbucketSelector"))
    }

    func test_selectors_shouldContainSelectorsFromSkippedSymbolsLists() {
        XCTAssert(sut.selectors.contains("list1Selector"))
        XCTAssert(sut.selectors.contains("list2Selector"))
    }
}
