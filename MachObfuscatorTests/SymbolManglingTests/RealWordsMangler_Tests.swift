import XCTest

class RealWordsMangler_Tests: XCTestCase {
    // TODO: tests missing

    private class IdentityRealWordsExportTrieMangling: RealWordsExportTrieMangling {
        func mangle(trie: Trie, fillingRootLabelWith labelFill: UInt8) -> Trie {
            return trie
        }
    }

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
            "zazzoollccXgeesslaaXjazznn",
            "zazzoollccYgeesslaaYjazznn"
        ]

        sut = RealWordsMangler(exportTrieMangler: IdentityRealWordsExportTrieMangling())
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
        let symbols = ObfuscationSymbols(whitelist: whitelist, blacklist: blacklist, exportTriesPerCpuIdPerURL: [:])

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
            "user" : "bla3",
            "view" : "bla1",
            "setUser:" : "setBla3:",
            "setView:" : "setBla1:"
        ]
        XCTAssert(mangledSymbols.selectors == firstVersion
            || mangledSymbols.selectors == secondVersion)
    }
    
    func test_mangleSymbols_shouldMangleAsciiSymbolToCorrectLength() {
        // Given
        
        let whitelist = ObjCSymbols(selectors: [ "asdf" ], classes: ["Asdf"])
        let blacklist = ObjCSymbols(selectors: [ "" ], classes: [])
        let symbols = ObfuscationSymbols(whitelist: whitelist, blacklist: blacklist, exportTriesPerCpuIdPerURL: [:])
        
        // When
        let mangledSymbols = when(symbols: symbols)
        
        // Then
        let expectedMangledBytes = 4
        XCTAssert(mangledSymbols.selectors["asdf"]!.utf8.count == expectedMangledBytes)
        XCTAssert(mangledSymbols.classNames["Asdf"]!.utf8.count == expectedMangledBytes)
    }
    
    func test_mangleSymbols_shouldMangleNonasciiSymbolToCorrectLength() {
        // Given
        
        let whitelist = ObjCSymbols(selectors: [ "zażółć:gęślą:jaźń" ], classes: ["Zażółć_gęślą_jaźń"])
        let blacklist = ObjCSymbols(selectors: [ "" ], classes: [])
        let symbols = ObfuscationSymbols(whitelist: whitelist, blacklist: blacklist, exportTriesPerCpuIdPerURL: [:])
        
        // When
        let mangledSymbols = when(symbols: symbols)
        
        // Then
        let expectedMangledBytes = 26 //counts 2 bytes per non-ascii character
        XCTAssert(mangledSymbols.selectors["zażółć:gęślą:jaźń"]!.utf8.count == expectedMangledBytes)
        XCTAssert(mangledSymbols.classNames["Zażółć_gęślą_jaźń"]!.utf8.count == expectedMangledBytes)
    }
}
