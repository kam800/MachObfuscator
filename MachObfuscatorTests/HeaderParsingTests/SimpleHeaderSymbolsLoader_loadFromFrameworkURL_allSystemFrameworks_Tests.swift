import XCTest

class SimpleHeaderSymbolsLoader_loadFromFrameworkURL_allSystemFrameworks_Tests: XCTestCase {

    // Disabled because it is very slow.
    func DISABLED_test_shouldParseSelectors() {
        // Given
        let sut = SimpleHeaderSymbolsLoader()

        // When
        let header = try! sut.load(forFrameworkURL: Paths.iosFrameworksRoot.asURL)

        // Assert
        XCTAssertFalse(header.selectors.isEmpty)
        XCTAssertFalse(header.classNames.isEmpty)
    }
}
