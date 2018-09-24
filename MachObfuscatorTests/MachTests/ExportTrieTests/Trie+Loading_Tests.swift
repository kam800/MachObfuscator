import XCTest

class Trie_Loading_Tests: XCTestCase {

    func test_trieShouldHaveNoChildren_whenChildCountIsZero() {
        // Given
        let payload = Data(bytes: [
            // Root node exported symbol information length
            0x00,
            // Root node child count
            0x00
        ])

        // When
        let sut = Trie(data: payload, rootNodeOffset: 0)

        // Then
        XCTAssertEqual(sut.children.count, 0)
    }

    func test_trieShouldHaveChildren_whenChildCountIsNonZero() {
        // Given
        let payload = Data(bytes: [
            // Root node exported symbol information length
            0x00,
            // Root node child count
            0x02,
            // #0 edge label
            0x41, 0x42, 0x00,
            // #0 node offset
            0x0a,
            // #1 edge label
            0x41, 0x43, 0x00,
            // #1 node offset
            0x0a,
            // Empty node
            0x00, 0x00
        ])

        // When
        let sut = Trie(data: payload, rootNodeOffset: 0)

        // Then
        XCTAssertEqual(sut.children.count, 2)
    }

    func test_rootTrieShouldAlwaysHaveEmptyLabel() {
        // Given
        let payload = Data(bytes: [
            // Root node exported symbol information length
            0x00,
            // Root node child count
            0x00,
        ])

        // When
        let sut = Trie(data: payload, rootNodeOffset: 4)

        // Then
        XCTAssert(sut.label.isEmpty)
        XCTAssert(sut.labelRange.isEmpty)
    }

    func test_childTriesShouldHaveLabelsOfGraphEdges() {
        // Given
        let payload = Data(bytes: [
            // Garbage
            0xab, 0xab, 0xab, 0xab,
            // Root node exported symbol information length
            0x00,
            // Root node child count
            0x02,
            // #0 edge label
            0x41, 0x42, 0x00,
            // #0 node offset
            0x0a,
            // #1 edge label
            0x41, 0x43, 0x00,
            // #1 node offset
            0x0a,
            // Empty node
            0x00, 0x00
        ])

        // When
        let sut = Trie(data: payload, rootNodeOffset: 4)

        // Then
        XCTAssertEqual(sut.children[0].label, [0x41, 0x42])
        XCTAssertEqual(sut.children[0].labelRange, 6..<8)
        XCTAssertEqual(sut.children[1].label, [0x41, 0x43])
        XCTAssertEqual(sut.children[1].labelRange, 10..<12)
    }

    func test_childTrieShouldExportSymbol_whenChildHasExportedSymbolInformation() {
        // Given
        let payload = Data(bytes: [
            // Garbage
            0xab, 0xab, 0xab, 0xab,
            // Root node exported symbol information length
            0x00,
            // Root node child count
            0x01,
            // #0 edge label
            0x41, 0x42, 0x00,
            // #0 node offset
            0x06,
            // Subnode exported symbol information length
            0x03,
            // Subnode exported symbol information
            0x00, 0x90, 0x4e,
            // Subnode child count
            0x00,
            // Empty node
            0x00, 0x00
        ])

        // When
        let sut = Trie(data: payload, rootNodeOffset: 4)

        // Then
        XCTAssert(sut.children[0].exportsSymbol)
    }

    func test_childTrieShouldNotExportSymbol_whenChildHasEmptyExportedSymbolInformation() {
        // Given
        let payload = Data(bytes: [
            // Garbage
            0xab, 0xab, 0xab, 0xab,
            // Root node exported symbol information length
            0x00,
            // Root node child count
            0x01,
            // #0 edge label
            0x41, 0x42, 0x00,
            // #0 node offset
            0x06,
            // Subnode exported symbol information length
            0x00,
            // Subnode child count
            0x00,
            // Empty node
            0x00, 0x00
        ])

        // When
        let sut = Trie(data: payload, rootNodeOffset: 4)

        // Then
        XCTAssertFalse(sut.children[0].exportsSymbol)
    }

    func test_shouldLoadNestedTries() {
        // Given
        let payload = Data(bytes: [
            // Garbage
            0xab, 0xab, 0xab, 0xab,

            // Root node exported symbol information length
            0x00,
            // Root node child count
            0x02,
            // #0 edge label
            0x41, 0x42, 0x00,
            // #0 node offset
            0x0a,
            // #1 edge label
            0x41, 0x43, 0x00,
            // #1 node offset
            0x18,

            // #0 exported symbol information length
            0x03,
            // #0 exported symbol information
            0x00, 0x90, 0x4e,
            // #0 child count
            0x01,
            // #2 edge label
            0x43, 0x44, 0x00,
            // #2 node offset
            0x13,

            // #2 exported symbol information length
            0x03,
            // #2 exported symbol information
            0x00, 0x90, 0x4e,
            // #2 child count
            0x00,

            // #1 exported symbol information length
            0x00,
            // #1 child count
            0x02,
            // #3 edge label
            0x44, 0x45, 0x00,
            // #3 node offset
            0x22,
            // #4 edge label
            0x46, 0x47, 0x00,
            // #4 node offset
            0x27,

            // #3 exported symbol information length
            0x03,
            // #3 exported symbol information
            0x00, 0x90, 0x4e,
            // #3 child count
            0x00,

            // #4 exported symbol information length
            0x03,
            // #4 exported symbol information
            0x00, 0x90, 0x4e,
            // #4 child count
            0x00,
        ])

        // When
        let sut = Trie(data: payload, rootNodeOffset: 4)

        // Then
        // Root node
        XCTAssertEqual(sut.children.count, 2)
        // #0 node
        XCTAssert(sut.children[0].exportsSymbol)
        XCTAssertEqual(sut.children[0].label, [ 0x41, 0x42 ])
        XCTAssertEqual(sut.children[0].children.count, 1)
        // #2 node
        XCTAssert(sut.children[0].children[0].exportsSymbol)
        XCTAssertEqual(sut.children[0].children[0].label, [ 0x43, 0x44 ])
        XCTAssert(sut.children[0].children[0].children.isEmpty)
        // #1 node
        XCTAssertFalse(sut.children[1].exportsSymbol)
        XCTAssertEqual(sut.children[1].label, [ 0x41, 0x43 ])
        XCTAssertEqual(sut.children[1].children.count, 2)
        // #3 node
        XCTAssert(sut.children[1].children[0].exportsSymbol)
        XCTAssertEqual(sut.children[1].children[0].label, [ 0x44, 0x45 ])
        XCTAssert(sut.children[1].children[0].children.isEmpty)
        // #4 node
        XCTAssert(sut.children[1].children[1].exportsSymbol)
        XCTAssertEqual(sut.children[1].children[1].label, [ 0x46, 0x47 ])
        XCTAssert(sut.children[1].children[1].children.isEmpty)
    }
}
