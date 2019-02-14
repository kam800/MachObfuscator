import XCTest

class RealWordsExportTrieMangler_Tests: XCTestCase {

    var sut: RealWordsExportTrieMangler!

    var rootTrie: Trie!

    override func setUp() {
        super.setUp()
        sut = RealWordsExportTrieMangler(machOViewDoomEnabled: false)
        var childrenLayer0 = trieChildren(number: 3)
        var childrenLayer1 = trieChildren(number: 2)
        var childrenLayer2 = trieChildren(number: 2)
        let childrenLayer3 = trieChildren(number: 2)

        childrenLayer2 = assignChildren(childrenLayer3, to: childrenLayer2)
        childrenLayer1 = assignChildren(childrenLayer2, to: childrenLayer1)
        childrenLayer0 = assignChildren(childrenLayer1, to: childrenLayer0)

        rootTrie = Trie(exportsSymbol: false,
                labelRange: 0..<1,
                label: [0],
                children: childrenLayer0)
    }

    override func tearDown() {
        sut = nil
        rootTrie = nil
    }

    func test_exportTrieObfuscationWithoutMachoViewDoom() {
        let obfuscatedTrie = sut.mangle(trie: rootTrie, fillingRootLabelWith: 0)
        XCTAssertEqual(obfuscatedTrie.label, [0])
        XCTAssertEqual(obfuscatedTrie.children[0].label, [1, 1, 1])
        XCTAssertEqual(obfuscatedTrie.children[0].children[1].label, [2, 2])
        XCTAssertEqual(obfuscatedTrie.children[1].label, [2, 2, 2])
        XCTAssertEqual(obfuscatedTrie.children[2].label, [3, 3, 3])
        XCTAssertEqual(obfuscatedTrie.children[2].children[0].label, [1, 1])
        XCTAssertEqual(obfuscatedTrie.children[2].children[1].label, [2, 2])
    }

    func test_exportTrieObfuscationWithMachoViewDoom() {
        sut = RealWordsExportTrieMangler(machOViewDoomEnabled: true)
        let obfuscatedTrie = sut.mangle(trie: rootTrie, fillingRootLabelWith: 0)
        XCTAssertEqual(obfuscatedTrie.label, [0])
        XCTAssertEqual(obfuscatedTrie.children[0].label, [0, 0, 0])
        XCTAssertEqual(obfuscatedTrie.children[0].children[1].label, [1, 1])
        XCTAssertEqual(obfuscatedTrie.children[0].label, [0, 0, 0])
        XCTAssertEqual(obfuscatedTrie.children[2].label, [2, 2, 2])
        XCTAssertEqual(obfuscatedTrie.children[2].children[0].label, [0, 0])
        XCTAssertEqual(obfuscatedTrie.children[2].children[1].label, [1, 1])
    }

    private func trieChildren(number: Int) -> [Trie] {
        return (1...number).map { index in
            return Trie(exportsSymbol: index % 2 == 0,
                    labelRange: 0..<UInt64(number),
                    label: randomLabels(count: number),
                    children: [])
        }
    }

    private func randomLabels(count: Int) -> [UInt8] {
        return  (0..<count).map { _ in
           return (UInt8.random(in: 1...UInt8.max))
        }
    }

    private func assignChildren(_ children: [Trie], to parent: [Trie]) -> [Trie] {
        return parent.map { (trie) in
            var copy = trie
            copy.children = children
            return copy
        }
    }
}
