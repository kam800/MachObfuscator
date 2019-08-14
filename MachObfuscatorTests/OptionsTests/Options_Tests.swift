import XCTest

class OptionsTestsSupport: XCTestCase {
    var argc: Int32!
    var argv: [String]!
    var unsafePtr: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>!

    func setUp(with _argv: [String]) {
        // First `argv` is path to executable. Add it here to not bother user in each `setUp` invocation.
        let argv = ["/path/to/obfuscator"] + _argv
        argc = Int32(argv.count)
        self.argv = argv
        let unsafePtr = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: argv.count)
        argv.enumerated().forEach { offset, element in
            let nestedPtr = UnsafeMutablePointer<Int8>.allocate(capacity: element.count + 1)
            nestedPtr.initialize(repeating: 0, count: element.count + 1)
            element.enumerated().forEach { charOffset, char in
                nestedPtr.advanced(by: charOffset).pointee = Int8(char.unicodeScalars.first!.value)
            }
            unsafePtr.advanced(by: offset).pointee = nestedPtr
        }
        self.unsafePtr = unsafePtr

        // Reset `getopt_long` for each test. According to man getopt(3):
        //
        // The variable optind is the index of the next element to be processed in argv. The system initializes this value to 1.
        // The caller can reset it to 1 to restart scanning of the same argv, or when scanning a new argument vector.
        optind = 1
    }

    override func tearDown() {
        (0 ..< argv.count).forEach { index in
            unsafePtr.advanced(by: index).pointee?.deallocate()
        }
        unsafePtr.deallocate()

        super.tearDown()
    }
}

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
