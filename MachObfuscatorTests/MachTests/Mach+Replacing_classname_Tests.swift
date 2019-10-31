//
//  Mach+Replacing_classname_Tests.swift
//  MachObfuscatorTests
//

import Foundation
import XCTest

private extension Mach {
    var classNamesInSection: [String] {
        guard let classnameSection = objcClassNameSection
        else { return [] }
        let classnameData = data.subdata(in: classnameSection.range.intRange)
        return classnameData.split(separator: 0).compactMap { String(bytes: $0, encoding: .utf8) }
    }
}

class Mach_Replacing_classname_Tests: XCTestCase {
    func test_shouldReplaceClassnamesInMach_WhenMatchingMangling() {
        // Given
        var sut = try! Image.load(url: URL.machoMacExecutable)

        // Prepare test obfuscation configuration satisfying requirements of replaceSymbols
        //
        // "Cat" is a category name, but it is not referenced in compiled metadata,
        // so use it as example of __objc_classname section entry that should not be changed.
        let map = SymbolManglingMap(selectors: [:], classNames: ["SampleClass": "ObfsctClazz", "Cat": "Bad", "NotExistingClass": "ShouldNotUse"], exportTrieObfuscationMap: [
            URL.machoMacExecutable: [
                sut.machs[0].cpu.asCpuId:
                    (unobfuscated: Trie.empty,
                     obfuscated: Trie.empty),
            ],
        ])
        var paths = ObfuscationPaths()
        paths.resolvedDylibMapPerImageURL = [URL.machoMacExecutable: [:]]

        // When
        sut.replaceSymbols(withMap: map, paths: paths)

        // Then
        XCTAssertFalse(sut.machs[0].classNamesInSection.contains("SampleClass"), "Should obfuscate class name")
        XCTAssertTrue(sut.machs[0].classNamesInSection.contains("ObfsctClazz"), "Should obfuscate class name")
        XCTAssertTrue(sut.machs[0].classNamesInSection.contains("Cat"), "Should not change not referenced name")
        XCTAssertFalse(sut.machs[0].classNamesInSection.contains("Bad"), "Should not change not referenced name")
        XCTAssertFalse(sut.machs[0].classNamesInSection.contains("ShouldNotUse"), "Should not use not existing name")
    }
}
