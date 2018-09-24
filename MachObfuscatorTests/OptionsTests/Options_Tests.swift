import XCTest

class Options_Tests: XCTestCase {

    var argc: Int32!
    var argv: [String]!
    var unsafePtr: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>!

    func setUp(with argv: [String]) {
        self.argc = Int32(argv.count)
        self.argv = argv
        let unsafePtr = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: argv.count)
        argv.enumerated().forEach { offset, element in
            let nestedPtr = UnsafeMutablePointer<Int8>.allocate(capacity: element.count + 1)
            nestedPtr.initialize(repeating: 0, count: element.count + 1)
            element.enumerated().forEach{ charOffset, char in
                nestedPtr.advanced(by: charOffset).pointee = Int8(char.unicodeScalars.first!.value)
            }
            unsafePtr.advanced(by: offset).pointee = nestedPtr
        }
        self.unsafePtr = unsafePtr
    }

    override func tearDown() {
        (0..<argv.count).forEach { index in
            unsafePtr.advanced(by: index).pointee?.deallocate()
        }
        unsafePtr.deallocate()

        super.tearDown()
    }

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
        setUp(with: [ "-q" ])

        // When
        let sut = Options(argc: argc,
                          unsafeArgv: unsafePtr,
                          argv: argv)

        // Then
        XCTAssertFalse(sut.quiet)
    }

    func test_init_withCommandLineParams_shouldSetVerbose_whenVSwitchPresent() {
        // Given
        setUp(with: [ "-v" ])

        // When
        let sut = Options(argc: argc,
                          unsafeArgv: unsafePtr,
                          argv: argv)

        // Then
        XCTAssertFalse(sut.verbose)
    }

    func test_init_withCommandLineParams_shouldSetAppDirectory_whenAdditionalArgumentPresent() {
        // Given
        let expectedAppDirectory = "/some/path"
        setUp(with: [ "-v", expectedAppDirectory ])

        // When
        let sut = Options(argc: argc,
                          unsafeArgv: unsafePtr,
                          argv: argv)

        // Then
        XCTAssertEqual(sut.appDirectory?.path, expectedAppDirectory)
    }
}
