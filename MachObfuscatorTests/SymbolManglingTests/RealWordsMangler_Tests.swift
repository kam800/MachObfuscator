import XCTest

class RealWordsMangler_Tests: XCTestCase {
    // TODO: tests missing

    var sentenceGenerator: ArraySentenceGenerator!
    var sut: RealWordsMangler!

    override func setUp() {
        super.setUp()

        sentenceGenerator = ArraySentenceGenerator()
        sentenceGenerator.sentences = [
            "bla1",
            "bla2",
            "bla3",
            "blaBla1",
            "blaBla2",
            "blaBla3",
        ]

        sut = RealWordsMangler()
    }

    override func tearDown() {
        sentenceGenerator = nil
        sut = nil

        super.tearDown()
    }

    private func when(symbols: ObfuscationSymbols) -> SymbolManglingMap {
        return sut.mangleSymbols(symbols, sentenceGenerator: sentenceGenerator)
    }

    func test_mangleSymbols_shouldMangleSettersAndGettersCoherently() {
        // Given
        let whitelist = ObjCSymbols(selectors: [ "user", "view", "setUser:", "setView:" ], classes: [])
        let blacklist = ObjCSymbols(selectors: [ "" ], classes: [])
        let symbols = ObfuscationSymbols(whitelist: whitelist,
                                                    blacklist: blacklist,
                                                    exportTriesPerCpuIdPerURL: [:])

        // When
        let mangledSymbols = when(symbols: symbols)

        // Then
        XCTAssertEqual(mangledSymbols.selectors,
                       [ "user" : "bla1",
                         "view" : "bla2",
                         "setUser:" : "setBla1:",
                         "setView:" : "setBla2:"
                       ])
    }
}
