@testable import App
import XCTest

private extension URL {
    init(forFramework framework: String, withPrefix prefix: String = "") {
        self.init(fileURLWithPath: "\(prefix)AppDir/Frameworks/\(framework).framework/\(framework)")
    }
}

class Options_ObfuscableFilesFilter_Tests: OptionsTestsSupport {
    private func assertAllUserFilesAreObfuscable(_ withWhitelist: ObfuscableFilesFilter, withPrefix prefix: String = "", file: StaticString = #file, line: UInt = #line) {
        XCTAssert(withWhitelist.isObfuscable(URL(fileURLWithPath: "\(prefix)AppDir/App")), "Application should be obfuscable", file: file, line: line)

        XCTAssert(withWhitelist.isObfuscable(URL(forFramework: "GoodFramework", withPrefix: prefix)), "GoodFramework should be obfuscable", file: file, line: line)
        XCTAssert(withWhitelist.isObfuscable(URL(forFramework: "BadFramework", withPrefix: prefix)), "BadFramework should be obfuscable", file: file, line: line)
        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "\(prefix)AppDir/libswiftcore.dylib")), "Embedded Swift runtime should not be obfuscable", file: file, line: line) // embedded lib
        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/SystemFrawework.framework/SystemFramework")), "System framework should not be obfuscable", file: file, line: line)
        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/libswift.dylib")), "Swift runtime should not be obfuscable", file: file, line: line)
    }

    func test_shouldObfuscateAppAndFrameworks_whenNoOptionsAreGiven() {
        // Given
        setUp(with: ["AppDir/App"])

        // When
        let sut = Options(argc: argc,
                          unsafeArgv: unsafePtr,
                          argv: argv)

        // Then
        let withWhitelist = sut.obfuscableFilesFilter
            // last condition is added automatically by Obfuscator
            .and(ObfuscableFilesFilter.onlyFiles(in: URL(fileURLWithPath: "AppDir")))

        // should obfuscate app and frameworks
        assertAllUserFilesAreObfuscable(withWhitelist)
    }

    func test_shouldObfuscateAppAndFrameworks_whenNoOptionsAreGiven_whenPathContainsDot() {
        // Given
        setUp(with: ["./AppDir"])

        // When
        let sut = Options(argc: argc,
                          unsafeArgv: unsafePtr,
                          argv: argv)

        // Then
        let withWhitelist = sut.obfuscableFilesFilter
            // last condition is added automatically by Obfuscator
            .and(ObfuscableFilesFilter.onlyFiles(in: URL(fileURLWithPath: "./AppDir")))

        // should obfuscate app and frameworks
        assertAllUserFilesAreObfuscable(withWhitelist)
    }

    func test_shouldObfuscateAppAndFrameworks_whenNoOptionsAreGiven_whenPathContainsDoubleDots() {
        // Given
        setUp(with: ["otherdir/../AppDir"])

        // When
        let sut = Options(argc: argc,
                          unsafeArgv: unsafePtr,
                          argv: argv)

        // Then
        let withWhitelist = sut.obfuscableFilesFilter
            // last condition is added automatically by Obfuscator
            .and(ObfuscableFilesFilter.onlyFiles(in: URL(fileURLWithPath: "otherdir/../AppDir")))

        // should obfuscate app and frameworks
        assertAllUserFilesAreObfuscable(withWhitelist)
    }

    func test_shouldObfuscateAppAndFrameworks_whenNoOptionsAreGiven_whenAbsolutePathContainsDoubleDots() {
        // Given
        setUp(with: ["/otherdir/../AppDir"])

        // When
        let sut = Options(argc: argc,
                          unsafeArgv: unsafePtr,
                          argv: argv)

        // Then
        let withWhitelist = sut.obfuscableFilesFilter
            // last condition is added automatically by Obfuscator
            .and(ObfuscableFilesFilter.onlyFiles(in: URL(fileURLWithPath: "/otherdir/../AppDir")))

        // should obfuscate app and frameworks
        assertAllUserFilesAreObfuscable(withWhitelist, withPrefix: "/")
    }

    func test_shouldObfuscateOnlyApp_whenSkipAllFrameworks() {
        // Given
        setUp(with: ["--skip-all-frameworks",
                     "AppDir/App"])

        // When
        let sut = Options(argc: argc,
                          unsafeArgv: unsafePtr,
                          argv: argv)

        // Then
        let withWhitelist = sut.obfuscableFilesFilter
            // last condition is added automatically by Obfuscator
            .and(ObfuscableFilesFilter.onlyFiles(in: URL(fileURLWithPath: "AppDir")))

        // should obfuscate app and nothing else
        XCTAssert(withWhitelist.isObfuscable(URL(fileURLWithPath: "AppDir/App")))

        XCTAssertFalse(withWhitelist.isObfuscable(URL(forFramework: "GoodFramework")))
        XCTAssertFalse(withWhitelist.isObfuscable(URL(forFramework: "BadFramework")))
        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "AppDir/libswiftcore.dylib"))) // embedded lib
        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/SystemFrawework.framework/SystemFramework")))
        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/libswift.dylib")))
    }

    func test_shouldObfuscateAppAndFrameworks_whenOnlyWhitelist() {
        // Given
        setUp(with: ["--obfuscate-framework", "GoodFramework",
                     "AppDir/App"])

        // When
        let sut = Options(argc: argc,
                          unsafeArgv: unsafePtr,
                          argv: argv)

        // Then
        let withWhitelist = sut.obfuscableFilesFilter
            // last condition is added automatically by Obfuscator
            .and(ObfuscableFilesFilter.onlyFiles(in: URL(fileURLWithPath: "AppDir")))

        // should obfuscate app and all fraweworks
        XCTAssert(withWhitelist.isObfuscable(URL(fileURLWithPath: "AppDir/App")))
        XCTAssert(withWhitelist.isObfuscable(URL(forFramework: "GoodFramework")))
        XCTAssert(withWhitelist.isObfuscable(URL(forFramework: "OtherFramework")))

        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "AppDir/libswiftcore.dylib"))) // embedded lib
        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/SystemFrawework.framework/SystemFramework")))
        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/libswift.dylib")))
    }

    func test_shouldObfuscateWhitelistedFrameworksAndNotOthers_whenSkipAllFrameworksAndWhitelist_whitelistFirst() {
        // Given
        setUp(with: ["--obfuscate-framework", "GoodFramework",
                     "--skip-all-frameworks",
                     "AppDir/App"])

        // When
        let sut = Options(argc: argc,
                          unsafeArgv: unsafePtr,
                          argv: argv)

        // Then
        let withWhitelist = sut.obfuscableFilesFilter
            // last condition is added automatically by Obfuscator
            .and(ObfuscableFilesFilter.onlyFiles(in: URL(fileURLWithPath: "AppDir")))

        // should obfuscate app and whitelisted fraweworks
        XCTAssert(withWhitelist.isObfuscable(URL(fileURLWithPath: "AppDir/App")))
        XCTAssert(withWhitelist.isObfuscable(URL(forFramework: "GoodFramework")))

        XCTAssertFalse(withWhitelist.isObfuscable(URL(forFramework: "BadFramework")))
        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "AppDir/libswiftcore.dylib"))) // embedded lib
        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/SystemFrawework.framework/SystemFramework")))
        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/libswift.dylib")))
    }

    func test_shouldObfuscateWhitelistedFrameworksAndNotOthers_whenSkipAllFrameworksAndWhitelist_skipAllFirst() {
        // Given
        setUp(with: ["--skip-all-frameworks",
                     "--obfuscate-framework", "GoodFramework",
                     "AppDir/App"])

        // When
        let sut = Options(argc: argc,
                          unsafeArgv: unsafePtr,
                          argv: argv)

        // Then
        let withWhitelist = sut.obfuscableFilesFilter
            // last condition is added automatically by Obfuscator
            .and(ObfuscableFilesFilter.onlyFiles(in: URL(fileURLWithPath: "AppDir")))

        // should obfuscate app and whitelisted fraweworks
        XCTAssert(withWhitelist.isObfuscable(URL(fileURLWithPath: "AppDir/App")))
        XCTAssert(withWhitelist.isObfuscable(URL(forFramework: "GoodFramework")))

        XCTAssertFalse(withWhitelist.isObfuscable(URL(forFramework: "BadFramework")))
        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "AppDir/libswiftcore.dylib"))) // embedded lib
        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/SystemFrawework.framework/SystemFramework")))
        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/libswift.dylib")))
    }

    func test_shouldObfuscateAllFrameworksExceptBlacklisted_whenSkipFrameworkAndWhitelist() {
        // Given
        setUp(with: ["--skip-framework", "BadFramework",
                     "--obfuscate-framework", "GoodFramework",
                     "AppDir/App"])

        // When
        let sut = Options(argc: argc,
                          unsafeArgv: unsafePtr,
                          argv: argv)

        // Then
        let withWhitelist = sut.obfuscableFilesFilter
            // last condition is added automatically by Obfuscator
            .and(ObfuscableFilesFilter.onlyFiles(in: URL(fileURLWithPath: "AppDir")))

        // should obfuscate app and not skipped fraweworks
        XCTAssert(withWhitelist.isObfuscable(URL(fileURLWithPath: "AppDir/App")))
        XCTAssert(withWhitelist.isObfuscable(URL(forFramework: "GoodFramework")))
        XCTAssert(withWhitelist.isObfuscable(URL(forFramework: "OtherFramework")))

        XCTAssertFalse(withWhitelist.isObfuscable(URL(forFramework: "BadFramework")))
        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "AppDir/libswiftcore.dylib"))) // embedded lib
        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/SystemFrawework.framework/SystemFramework")))
        XCTAssertFalse(withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/libswift.dylib")))
    }
}
