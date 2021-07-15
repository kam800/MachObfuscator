@testable import App
import XCTest

class RealWordsExportTrieMangler_Tests: XCTestCase {
    private var sut: RealWordsExportTrieMangler!
    private var rootTrie: Trie!

    override func setUp() {
        super.setUp()
        sut = RealWordsExportTrieMangler(machOViewDoomEnabled: false)

        rootTrie = Trie.testTrie(levels: [
            (labelLength: 1, childrenCount: 3),
            (labelLength: 3, childrenCount: 3),
            (labelLength: 2, childrenCount: 2),
            (labelLength: 2, childrenCount: 2),
            (labelLength: 2, childrenCount: 0),
        ])
    }

    override func tearDown() {
        sut = nil
        rootTrie = nil
        super.tearDown()
    }

    func test_exportTrieObfuscationWithoutMachoViewDoom() {
        let obfuscatedTrie = sut.mangle(trie: rootTrie)
        XCTAssertEqual(obfuscatedTrie.label, [1])
        XCTAssertEqual(obfuscatedTrie.children[0].label, [1, 1, 1])
        XCTAssertEqual(obfuscatedTrie.children[0].children[1].label, [2, 2])
        XCTAssertEqual(obfuscatedTrie.children[1].label, [2, 2, 2])
        XCTAssertEqual(obfuscatedTrie.children[2].label, [3, 3, 3])
        XCTAssertEqual(obfuscatedTrie.children[2].children[0].label, [1, 1])
        XCTAssertEqual(obfuscatedTrie.children[2].children[1].label, [2, 2])
    }

    func test_exportTrieObfuscationWithMachoViewDoom() {
        sut = RealWordsExportTrieMangler(machOViewDoomEnabled: true)
        let obfuscatedTrie = sut.mangle(trie: rootTrie)
        XCTAssertEqual(obfuscatedTrie.label, [0])
        XCTAssertEqual(obfuscatedTrie.children[0].label, [0, 0, 0])
        XCTAssertEqual(obfuscatedTrie.children[0].children[1].label, [1, 1])
        XCTAssertEqual(obfuscatedTrie.children[0].label, [0, 0, 0])
        XCTAssertEqual(obfuscatedTrie.children[2].label, [2, 2, 2])
        XCTAssertEqual(obfuscatedTrie.children[2].children[0].label, [0, 0])
        XCTAssertEqual(obfuscatedTrie.children[2].children[1].label, [1, 1])
    }
}

private typealias TrieLevel = (labelLength: Int, childrenCount: Int)

private extension Trie {
    static func testTrie(levels: [TrieLevel]) -> Trie {
        guard !levels.isEmpty else {
            return Trie(exportsSymbol: true,
                        labelRange: 0 ..< 3,
                        label: [UInt8].random(count: 3),
                        children: [])
        }

        let headLevel = levels[0]
        let tailLevels = Array(levels.suffix(from: 1))
        let children = tailLevels.isEmpty
            ? []
            : (0 ..< headLevel.childrenCount).map { _ in testTrie(levels: tailLevels) }
        return Trie(exportsSymbol: tailLevels.count % 2 == 0,
                    labelRange: 0 ..< UInt64(headLevel.labelLength),
                    label: [UInt8].random(count: headLevel.labelLength),
                    children: children)
    }
}

private extension Array where Element == UInt8 {
    static func random(count: Int) -> [UInt8] {
        return (0 ..< count).map { _ in
            UInt8.random(in: 1 ... UInt8.max)
        }
    }
}
