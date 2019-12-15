import XCTest

class ObjectSymbols_Blacklisting_blackListWithSkippedSymbolsLists_Tests: XCTestCase {
    var testSymbolsListLoader: ObjectSymbolsLoaderMock! = ObjectSymbolsLoaderMock()
    var sut: ObjectSymbols!

    override func setUp() {
        super.setUp()

        testSymbolsListLoader["/tmp/list1.txt"] = ObjectSymbols(
            selectors: ["list1Selector"],
            classNames: ["list1Class"]
        )

        testSymbolsListLoader["/tmp/list2.txt"] = ObjectSymbols(
            selectors: ["list2Selector"],
            classNames: ["list2Class"]
        )

        sut = ObjectSymbols.blacklist(skippedSymbolsLists: ["/tmp/list1.txt".asURL,
                                                            "/tmp/list2.txt".asURL],
                                      symbolsListLoader: testSymbolsListLoader)
    }

    override func tearDown() {
        sut = nil
        testSymbolsListLoader = nil

        super.tearDown()
    }

    func test_classNames_shouldContainClassNamesFromSkippedSymbolsLists() {
        XCTAssert(sut.classNames.contains("list1Class"))
        XCTAssert(sut.classNames.contains("list2Class"))
    }

    func test_selectors_shouldContainSelectorsFromSkippedSymbolsLists() {
        XCTAssert(sut.selectors.contains("list1Selector"))
        XCTAssert(sut.selectors.contains("list2Selector"))
    }
}
