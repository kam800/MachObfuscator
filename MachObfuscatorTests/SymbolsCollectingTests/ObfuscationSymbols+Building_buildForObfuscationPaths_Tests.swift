import XCTest

class ObfuscationSymbols_Building_buildForObfuscationPaths_Tests: XCTestCase {

    var sampleObfuscationPaths: ObfuscationPaths! = ObfuscationPaths()
    var testLoader: ObfuscationSymbolsTestSymbolsSourceLoader! = ObfuscationSymbolsTestSymbolsSourceLoader()
    var sut: ObfuscationSymbols!

    override func setUp() {
        super.setUp()

        sampleObfuscationPaths.obfuscableImages = [
            URL(fileURLWithPath: "/tmp/ob1"), URL(fileURLWithPath: "/tmp/ob2")
        ]
        sampleObfuscationPaths.unobfuscableDependencies = [
            URL(fileURLWithPath: "/tmp/x1"), URL(fileURLWithPath: "/tmp/x2")
        ]
        testLoader["/tmp/ob1"] = [
            SymbolsSourceMock.with(selectors: ["s1", "s2"],
                                   classNames: ["c1", "c2"],
                                   exportedTrie: Trie.with(label: "ob1t1"),
                                   cpuType: 0x17,
                                   cpuSubtype: 0x42),
            SymbolsSourceMock.with(selectors: ["s1", "s3"],
                                   classNames: ["c1", "c3"],
                                   cstrings: ["s4", "c4"],
                                   exportedTrie: Trie.with(label: "ob1t2"),
                                   cpuType: 0x17,
                                   cpuSubtype: 0x43)
        ]
        testLoader["/tmp/ob2"] = [
            SymbolsSourceMock.with(selectors: ["s1", "s2", "s5", "s6", "s7"],
                                   classNames: ["c1", "c2", "c5", "c6", "c7"],
                                   exportedTrie: Trie.with(label: "ob2"),
                                   cpuType: 0x17,
                                   cpuSubtype: 0x42)
        ]
        testLoader["/tmp/x1"] = [
            SymbolsSourceMock.with(selectors: ["s2"],
                                   classNames: ["c2"])
        ]
        testLoader["/tmp/x2"] = [
            SymbolsSourceMock.with(selectors: ["s5"],
                                   classNames: ["c5"],
                                   cstrings: ["s6", "c6"])
        ]

        sut = buildSUT()
    }

    func buildSUT() -> ObfuscationSymbols {
        return ObfuscationSymbols.buildFor(obfuscationPaths: sampleObfuscationPaths,
                                           loader: testLoader)
    }

    func test_whitelistSelectors_shouldContainObfuscableImagesSelectorsWithoutUnobfuscableDependenciesSelectorsAndCstrings() {
        XCTAssertEqual(sut.whitelist.selectors, [ "s1", "s3", "s7"])
    }

    func test_whitelistClassNames_shouldContainObfuscableImagesClassNamesWithoutUnobfuscableDependenciesClassNamesAndCstrings() {
        XCTAssertEqual(sut.whitelist.classes, [ "c1", "c3", "c7"])
    }

    func test_blacklistSelectors_shouldContainUnobfuscableDependenciesSelectorsAndCstrings() {
        XCTAssertEqual(sut.blacklist.selectors, [ "s2", "setS2:", "s5", "setS5:", "s6", "setS6:", "c6", "setC6:"])
    }

    func test_blacklistClassNames_shouldContainUnobfuscableDependenciesClassNamesAndCstrings() {
        XCTAssertEqual(sut.blacklist.classes, [ "c2", "c5", "c6", "s6"])
    }

    func test_exportTriesPerURL_shouldContainTriesOfObfuscableImages() {
        let ob1TriePerCpuId: [CpuId: Trie]! = sut.exportTriesPerCpuIdPerURL[URL(fileURLWithPath: "/tmp/ob1")]
        XCTAssertNotNil(ob1TriePerCpuId)
        XCTAssertEqual(ob1TriePerCpuId.count, 2)
        XCTAssertEqual(ob1TriePerCpuId[0x1700000042]?.labelString, "ob1t1")
        XCTAssertEqual(ob1TriePerCpuId[0x1700000043]?.labelString, "ob1t2")

        let ob2TriePerCpuId: [CpuId: Trie]! = sut.exportTriesPerCpuIdPerURL[URL(fileURLWithPath: "/tmp/ob2")]
        XCTAssertNotNil(ob2TriePerCpuId)
        XCTAssertEqual(ob2TriePerCpuId.count, 1)
        XCTAssertEqual(ob2TriePerCpuId[0x1700000042]?.labelString, "ob2")
    }
}
