//
//  Mach+Replacing_propertyattributes_Tests.swift
//  MachObfuscatorTests
//

import Foundation
import XCTest

private extension ObjcClass {
    func property(_ name: String) -> ObjcProperty? {
        return properties.first { $0.name.value == name }
    }
}

class Mach_Replacing_propertyattributes_Tests: XCTestCase {
    func test_shouldReplaceClassnamesInMach_WhenMatchingMangling() {
        // Given
        var sut = try! Image.load(url: URL.machoIos12_0Executable)

        // Prepare test obfuscation configuration satisfying requirements of replaceSymbols
        let emptyTrie = Trie(exportsSymbol: false, labelRange: 0 ..< 0, label: [], children: [])
        let firstImportEntry = sut.machs[0].importStack[0]
        let symbolDylib = sut.machs[0].dylibs[firstImportEntry.dylibOrdinal - 1]

        // In normal case NSString would not be obfuscated. In test we use it because it is referenced in property types
        let map = SymbolManglingMap(selectors: [:], classNames: ["NSString": "ObfStrng"], exportTrieObfuscationMap: [
            URL.machoIos12_0Executable: [
                sut.machs[0].cpu.asCpuId:
                    (unobfuscated: emptyTrie,
                     obfuscated: emptyTrie),
            ],
        ])
        var paths = ObfuscationPaths()
        paths.resolvedDylibMapPerImageURL = [URL.machoIos12_0Executable: [symbolDylib: URL(fileURLWithPath: "/tmp/testlib")]]

        // When
        sut.replaceSymbols(withMap: map, paths: paths)

        // Then
        let sampleClass = sut.machs[0].objcClasses.first { $0.name.value == "SampleClass" }

        XCTAssertEqual(sampleClass?.property("dynamicSampleProperty")?.typeAttribute, "T@\"ObfStrng\"")
        XCTAssertEqual(sampleClass?.property("additionalDynamicProperty")?.typeAttribute, "T@\"ObfStrng\"")
        XCTAssertEqual(sampleClass?.property("additionalNonDynamicProperty")?.typeAttribute, "T@\"ObfStrng\"")

        let viewController = sut.machs[0].objcClasses.first { $0.name.value == "_TtC12SampleIosApp14ViewController" }
        XCTAssertEqual(viewController?.property("counterLabel")?.typeAttribute, "T@\"UILabel\"", "Should not change property type that is not obfuscated")
    }
}
