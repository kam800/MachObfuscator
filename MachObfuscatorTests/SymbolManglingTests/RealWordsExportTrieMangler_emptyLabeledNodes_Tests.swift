import XCTest

class RealWordsExportTrieMangler_emptyLabeledNodes_Tests: XCTestCase {
    private var sut: RealWordsExportTrieMangler!

    override func setUp() {
        super.setUp()
        sut = RealWordsExportTrieMangler(machOViewDoomEnabled: false)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_shouldProduceUniqueSymbols() {
        // Given
        let trie =
            node([3], [
                node([5], [
                    node([8]),
                    node([13]),
                    node([], [
                        node([21]),
                        node([], [
                            node([34]),
                        ]),
                        node([55]),
                    ]),
                    node([], [
                        node([89], [
                            node([144]),
                            node([233]),
                        ]),
                    ]),
                ]),
                node([250]),
            ])

        let expectedTrie =
            node([1], [
                node([1], [
                    node([1]),
                    node([2]),
                    node([], [
                        node([3]),
                        node([], [
                            node([4]),
                        ]),
                        node([5]),
                    ]),
                    node([], [
                        node([6], [
                            node([1]),
                            node([2]),
                        ]),
                    ]),
                ]),
                node([2]),
            ])

        // When
        let obfuscatedTrie = sut.mangle(trie: trie)

        // Then
        XCTAssert(obfuscatedTrie.exportedLabelStrings.containsUniqueElements)
        assertEqual(obfuscatedTrie, expectedTrie)
    }
}

private extension RealWordsExportTrieMangler_emptyLabeledNodes_Tests {
    func assertEqual(_ trie1: Trie, _ trie2: Trie, pathSoFar: [Int] = [], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(trie1.label, trie2.label, "Unexpected labels at path \(pathSoFar)", file: file, line: line)
        zip(trie1.children, trie2.children).enumerated().forEach { idx, correspondingChildren in
            assertEqual(correspondingChildren.0, correspondingChildren.1, pathSoFar: pathSoFar + [idx], file: file, line: line)
        }
    }
}

private extension Array where Element: Hashable {
    var containsUniqueElements: Bool {
        return count == Set(self).count
    }
}

private func node(_ label: [UInt8], _ children: [Trie] = []) -> Trie {
    return Trie(exportsSymbol: !label.isEmpty,
                labelRange: 0 ..< UInt64(label.count),
                label: label,
                children: children)
}
