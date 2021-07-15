@testable import App
import XCTest

class Trie_Parsing_Tests: XCTestCase {
    let samplePayload = Data([
        // Garbage
        0xAB, 0xAB, 0xAB, 0xAB,

        // Root node exported symbol information length
        0x00,
        // Root node child count
        0x02,
        // #0 edge label
        0x41, 0x42, 0x00,
        // #0 node offset
        0x0A,
        // #1 edge label
        0x41, 0x43, 0x00,
        // #1 node offset
        0x18,

        // #0 exported symbol information length
        0x03,
        // #0 exported symbol information
        0x00, 0x90, 0x4E,
        // #0 child count
        0x01,
        // #2 edge label
        0x43, 0x44, 0x00,
        // #2 node offset
        0x13,

        // #2 exported symbol information length
        0x03,
        // #2 exported symbol information
        0x00, 0x90, 0x4E,
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
        0x00, 0x90, 0x4E,
        // #3 child count
        0x00,

        // #4 exported symbol information length
        0x03,
        // #4 exported symbol information
        0x00, 0x90, 0x4E,
        // #4 child count
        0x00,
    ])

    func test_exportedLabelsString_shouldListFullExportedSymbols() {
        // Given
        let sut = Trie(data: samplePayload, rootNodeOffset: 4)

        // Expect
        XCTAssertEqual(sut.exportedLabelStrings,
                       ["AB", "ABCD", "ACDE", "ACFG"])
    }

    func test_flatNodes_shouldReturnFlatNodesList() {
        // Given
        let sut = Trie(data: samplePayload, rootNodeOffset: 4)

        // When
        let nodes = sut.flatNodes

        // Then
        XCTAssertEqual(nodes.count, 6)
        XCTAssertEqual(nodes.map { $0.labelString },
                       ["", "AB", "AC", "DE", "FG", "CD"])
    }
}
