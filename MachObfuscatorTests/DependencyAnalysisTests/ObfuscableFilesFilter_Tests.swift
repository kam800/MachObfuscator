//
//  ObfuscableFilesFilter.swift
//  MachObfuscatorTests
//

import XCTest

private extension URL {
    init(forFramework framework: String) {
        self.init(fileURLWithPath: "AppDir/Frameworks/\(framework).framework/\(framework)")
    }
}

class ObfuscableFilesFilter_Tests: XCTestCase {
    func test_shouldObfuscateOnlyApp_whenSkipAllFrameworks() {
        let withWhitelist = ObfuscableFilesFilter.defaultObfuscableFilesFilter()
            .and(ObfuscableFilesFilter.skipAllFrameworks())
            // last condition is added automatically by Obfuscator
            .and(ObfuscableFilesFilter.onlyFiles(in: URL(fileURLWithPath: "AppDir")))

        // should obfuscate app and nothing else
        XCTAssert(withWhitelist.isObfuscable(URL(fileURLWithPath: "AppDir/App")))

        XCTAssert(!withWhitelist.isObfuscable(URL(forFramework: "GoodFramework")))
        XCTAssert(!withWhitelist.isObfuscable(URL(forFramework: "BadFramework")))
        XCTAssert(!withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/SystemFrawework.framework/SystemFramework")))
        XCTAssert(!withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/libswift.dylib")))
    }

    func test_shouldObfuscateWhitelistedFrameworksAndNotOthers_whenSkipAllFrameworksAndWhitelist() {
        let withWhitelist = ObfuscableFilesFilter.defaultObfuscableFilesFilter()
            .and(ObfuscableFilesFilter.skipAllFrameworks())
            .whitelist(ObfuscableFilesFilter.isFramework(framework: "GoodFramework"))
            // last condition is added automatically by Obfuscator
            .and(ObfuscableFilesFilter.onlyFiles(in: URL(fileURLWithPath: "AppDir")))

        // should obfuscate app and whitelisted fraweworks
        XCTAssert(withWhitelist.isObfuscable(URL(fileURLWithPath: "AppDir/App")))
        XCTAssert(withWhitelist.isObfuscable(URL(forFramework: "GoodFramework")))

        XCTAssert(!withWhitelist.isObfuscable(URL(forFramework: "BadFramework")))
        XCTAssert(!withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/SystemFrawework.framework/SystemFramework")))
        XCTAssert(!withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/libswift.dylib")))
    }

    func test_shouldObfuscateCorrectFrameworksAndNotOthers_whenSkipFrameworkAndWhitelist() {
        let withWhitelist = ObfuscableFilesFilter.defaultObfuscableFilesFilter()
            .and(ObfuscableFilesFilter.skipFramework(framework: "BadFramework"))
            .whitelist(ObfuscableFilesFilter.isFramework(framework: "GoodFramework"))
            // last condition is added automatically by Obfuscator
            .and(ObfuscableFilesFilter.onlyFiles(in: URL(fileURLWithPath: "AppDir")))

        // should obfuscate app and not skipped fraweworks
        XCTAssert(withWhitelist.isObfuscable(URL(fileURLWithPath: "AppDir/App")))
        XCTAssert(withWhitelist.isObfuscable(URL(forFramework: "GoodFramework")))
        XCTAssert(withWhitelist.isObfuscable(URL(forFramework: "OtherFramework")))

        XCTAssert(!withWhitelist.isObfuscable(URL(forFramework: "BadFramework")))
        XCTAssert(!withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/SystemFrawework.framework/SystemFramework")))
        XCTAssert(!withWhitelist.isObfuscable(URL(fileURLWithPath: "/usr/lib/system/libswift.dylib")))
    }
}
