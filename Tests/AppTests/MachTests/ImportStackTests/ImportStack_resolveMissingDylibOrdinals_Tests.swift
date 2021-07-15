@testable import App
import XCTest

class ImportStack_resolveMissingDylibOrdinals_Tests: XCTestCase {
    var sut: ImportStack! = ImportStack()

    override func setUp() {
        super.setUp()

        // Given
        sut.append(ImportStackEntry(dylibOrdinal: 1, symbol: [0x41], symbolRange: 0 ..< 1, weak: false))
        sut.append(ImportStackEntry(dylibOrdinal: 2, symbol: [0x42], symbolRange: 0 ..< 1, weak: false))
        sut.append(ImportStackEntry(dylibOrdinal: 3, symbol: [0x43], symbolRange: 0 ..< 1, weak: false))
        sut.append(ImportStackEntry(dylibOrdinal: 4, symbol: [0x43], symbolRange: 0 ..< 1, weak: false))
        sut.append(ImportStackEntry(dylibOrdinal: 0, symbol: [0x42], symbolRange: 0 ..< 1, weak: false))
        sut.append(ImportStackEntry(dylibOrdinal: 0, symbol: [0x43], symbolRange: 0 ..< 1, weak: false))
        sut.append(ImportStackEntry(dylibOrdinal: 0, symbol: [0x43], symbolRange: 0 ..< 1, weak: true))
        sut.append(ImportStackEntry(dylibOrdinal: 0, symbol: [0x44], symbolRange: 0 ..< 1, weak: true))

        // When
        sut.resolveMissingDylibOrdinals()
    }

    func test_shouldUpdateZeroDylibOrdinalsWithAlreadyResolvedOrdinals() {
        // Then
        XCTAssertEqual(sut[4].dylibOrdinal, 2)
        XCTAssertEqual(sut[5].dylibOrdinal, 3)
        XCTAssertEqual(sut[6].dylibOrdinal, 3)
    }

    func test_shouldNotChangeAlreadyResolvedOrdinals() {
        // Then
        XCTAssertEqual(sut[0].dylibOrdinal, 1)
        XCTAssertEqual(sut[1].dylibOrdinal, 2)
        XCTAssertEqual(sut[2].dylibOrdinal, 3)
        XCTAssertEqual(sut[3].dylibOrdinal, 4)
    }

    func test_shouldNotFailWhenUnresolvableWeakEntry() {
        // Then
        XCTAssertEqual(sut[7].dylibOrdinal, 0)
    }
}
