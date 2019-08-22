import XCTest

class Options_Tests: OptionsTestsSupport {
    func test_init_withCommandLineParams_shouldLeaveDefaultParams_whenEmptyArgv() {
        // Given
        setUp(with: [])

        // When
        let sut = Options(argc: argc,
                          unsafeArgv: unsafePtr,
                          argv: argv)

        // Then
        XCTAssertFalse(sut.quiet)
        XCTAssertFalse(sut.verbose)
        XCTAssertNil(sut.appDirectory)
    }

    func test_init_withCommandLineParams_shouldSetQuiet_whenQSwitchPresent() {
        // Given
        setUp(with: ["-q"])

        // When
        let sut = Options(argc: argc,
                          unsafeArgv: unsafePtr,
                          argv: argv)

        // Then
        XCTAssertTrue(sut.quiet)
    }

    func test_init_withCommandLineParams_shouldSetVerbose_whenVSwitchPresent() {
        // Given
        setUp(with: ["-v"])

        // When
        let sut = Options(argc: argc,
                          unsafeArgv: unsafePtr,
                          argv: argv)

        // Then
        XCTAssertTrue(sut.verbose)
    }

    func test_init_withCommandLineParams_shouldSetAppDirectory_whenAdditionalArgumentPresent() {
        // Given
        let expectedAppDirectory = "/some/path"
        setUp(with: ["-v", expectedAppDirectory])

        // When
        let sut = Options(argc: argc,
                          unsafeArgv: unsafePtr,
                          argv: argv)

        // Then
        XCTAssertEqual(sut.appDirectory?.path, expectedAppDirectory)
    }
}
