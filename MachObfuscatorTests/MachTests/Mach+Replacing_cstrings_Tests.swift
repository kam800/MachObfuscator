//
//  Mach+Replacing_cstrings_Tests.swift
//  MachObfuscatorTests
//

import XCTest

class Mach_Replacing_cstring_Tests: XCTestCase {
    var sut: Image!
    var originalCstrings: Set<String>!
    // These propeties require that `cstrings` reflects current state of image data (i.e. is not lazily computed and later not updated)
    var currentCstrings: Set<String> { return Set(sut.machs[0].cstrings) }
    var newCstrings: Set<String> { return currentCstrings.subtracting(originalCstrings) }
    var removedCstrings: Set<String> { return originalCstrings.subtracting(currentCstrings) }

    override func setUp() {
        super.setUp()

        sut = try! Image.load(url: URL.machoMacExecutable)
        originalCstrings = currentCstrings
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    private func assertNothingChanged(file: StaticString = #file, line: UInt = #line) {
        XCTAssert(newCstrings.isEmpty, "newCstrings should be empty", file: file, line: line)
        XCTAssert(removedCstrings.isEmpty, "removedCstrings should be empty", file: file, line: line)
    }

    // ---------- Cstring replacing tests ----------
    func test_shouldNotReplaceCstring_WhenMappingIsEmpty() {
        sut.replaceCstrings(mapping: [:])
        assertNothingChanged()
    }

    func test_shouldReplaceCstring_WhenFullStringMatches() {
        sut.replaceCstrings(mapping: ["debugDescription": "OBFOBFOBFOBF"])
        XCTAssertEqual(newCstrings, ["OBFOBFOBFOBF"])
        XCTAssertEqual(removedCstrings, ["debugDescription"])
    }

    func test_shouldReplaceManyCstrings_WhenFullStringMatches() {
        sut.replaceCstrings(mapping: ["debugDescription": "OBFOBFOBFOBF", "Fatal error": "ERROR"])
        XCTAssertEqual(newCstrings, ["OBFOBFOBFOBF", "ERROR"])
        XCTAssertEqual(removedCstrings, ["debugDescription", "Fatal error"])
    }

    func test_shouldReplaceMatchingCstrings_WhenNotAllMatch() {
        sut.replaceCstrings(mapping: ["debugDescription": "OBFOBFOBFOBF", "Fatal err": "ERROR", "Text not in the image": "Dummy"])
        XCTAssertEqual(newCstrings, ["OBFOBFOBFOBF"])
        XCTAssertEqual(removedCstrings, ["debugDescription"])
    }

    func test_shouldNotReplaceCstring_WhenOnlyPrefixMatches() {
        sut.replaceCstrings(mapping: ["debugDescr": "OBFOBFOBFOBF"])
        assertNothingChanged()
    }

    func test_shouldNotReplaceFilenames_WhenPrefixListIsEmpty() {
        sut.eraseFilePaths([], usingReplacement: "FILENAME_REMOVED")
        assertNothingChanged()
    }

    // ---------- Filename erasing tests ----------
    func test_shouldEraseFilename_WhenPrefixMatches() {
        sut.eraseFilePaths(["/Users/kamil.borzym"], usingReplacement: "FILENAME_REMOVED")

        XCTAssertEqual(newCstrings, ["FILENAME_REMOVED"])
        XCTAssertEqual(removedCstrings, ["/Users/kamil.borzym/prv/src/MachObfuscator/MachObfuscatorTests/SampleAppSources/SampleMacApp/SampleMacApp/ViewController.swift"])
    }

    func test_shouldEraseMatchingFilename_WhenPrefixMatches() {
        sut.eraseFilePaths(["/Users/kamil.borzym", "/Users/admin"], usingReplacement: "FILENAME_REMOVED")

        XCTAssertEqual(newCstrings, ["FILENAME_REMOVED"])
        XCTAssertEqual(removedCstrings, ["/Users/kamil.borzym/prv/src/MachObfuscator/MachObfuscatorTests/SampleAppSources/SampleMacApp/SampleMacApp/ViewController.swift"])
    }

    func test_shouldNotEraseFilename_WhenPrefixDoesNotMatch() {
        sut.eraseFilePaths(["/Users/admin"], usingReplacement: "FILENAME_REMOVED")
        assertNothingChanged()
    }
}
