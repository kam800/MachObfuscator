import XCTest

class RecursiveSourceSymbolsLoader_loadFromFrameworkURL_allSystemFrameworks_Tests: XCTestCase {
    // Disabled because it is very slow.
    func DISABLED_test_shouldParseSelectors() {
        // Given
        let sut = RecursiveSourceSymbolsLoader()

        // When
        let header = try! sut.load(fromDirectory: Paths.iosFrameworksRoot.asURL)

        // Assert
        XCTAssertFalse(header.selectors.isEmpty)
        XCTAssertFalse(header.classNames.isEmpty)
    }
}
