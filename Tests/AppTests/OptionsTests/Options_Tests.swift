@testable import App
import XCTest

class Options_Tests: OptionsTestsSupport {
    func test_init_withCommandLineParams_shouldLeaveDefaultParams_whenEmptyArgv() {
        // Given
        setUp(with: [])

        // When
        let sut = createSut()

        // Then
        XCTAssertFalse(sut.quiet)
        XCTAssertFalse(sut.verbose)
        XCTAssertNil(sut.appDirectoryOrFile)
    }

    func test_init_withCommandLineParams_shouldSetQuiet_whenQSwitchPresent() {
        // Given
        setUp(with: ["-q"])

        // When
        let sut = createSut()

        // Then
        XCTAssertTrue(sut.quiet)
    }

    func test_init_withCommandLineParams_shouldSetVerbose_whenVSwitchPresent() {
        // Given
        setUp(with: ["-v"])

        // When
        let sut = createSut()

        // Then
        XCTAssertTrue(sut.verbose)
    }

    func test_init_withCommandLineParams_shouldSetAppDirectory_whenAdditionalArgumentPresent() {
        // Given
        let expectedAppDirectory = "/some/path"
        setUp(with: ["-v", expectedAppDirectory])

        // When
        let sut = createSut()

        // Then
        XCTAssertEqual(sut.appDirectoryOrFile?.path, expectedAppDirectory)
    }

    func test_init_withCommandLineParams_shouldSetSkippedSymbolsLists() {
        // Given
        let expectedFilePath = "/some/path/to/file.txt"
        setUp(with: ["--skip-symbols-from-list", expectedFilePath])

        // When
        let sut = createSut()

        // Then
        XCTAssertEqual(sut.skippedSymbolsLists, [URL(fileURLWithPath: expectedFilePath)])
    }
}
