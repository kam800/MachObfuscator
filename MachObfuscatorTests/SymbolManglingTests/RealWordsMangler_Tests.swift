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
        let firstVersion = [
            "user" : "bla1",
            "view" : "bla2",
            "setUser:" : "setBla1:",
            "setView:" : "setBla2:"
        ]
        let secondVersion = [
            "user" : "bla2",
            "view" : "bla1",
            "setUser:" : "setBla2:",
            "setView:" : "setBla1:"
        ]
        XCTAssert(mangledSymbols.selectors == firstVersion
            || mangledSymbols.selectors == secondVersion)
    }

    func test_mangleSymbols_shouldSkipBlacklistedSettersAndGettersCoherently() {
        // Given
        let whitelist = ObjCSymbols(selectors: [ "user", "view", "setUser:", "setView:" ], classes: [])
        let blacklist = ObjCSymbols(selectors: [ "bla2" ], classes: [])
        let symbols = ObfuscationSymbols(whitelist: whitelist,
                                         blacklist: blacklist,
                                         exportTriesPerCpuIdPerURL: [:])

        // When
        let mangledSymbols = when(symbols: symbols)

        // Then
        let firstVersion = [
            "user" : "bla1",
            "view" : "bla3",
            "setUser:" : "setBla1:",
            "setView:" : "setBla3:"
        ]
        let secondVersion = [
            "user" : "bla1",
            "view" : "bla3",
            "setUser:" : "setBla1:",
            "setView:" : "setBla3:"
        ]
        XCTAssert(mangledSymbols.selectors == firstVersion
            || mangledSymbols.selectors == secondVersion)
    }
}
