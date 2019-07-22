//
//  Mach+Replacing_methtype_Tests.swift
//  MachObfuscatorTests
//

import XCTest

private extension Mach {
    var methTypes: [String] {
        guard let methtypeSection = objcMethTypeSection
            else { return [] }
        let methtypeData = data.subdata(in: methtypeSection.range.intRange)
        return methtypeData.split(separator: 0).compactMap { String(bytes: $0, encoding: .utf8) }
    }
}

class Mach_Replacing_methtype_Tests: XCTestCase {
    let testMap = SymbolManglingMap(selectors: [:], classNames: ["MyClass" : "ObfClss", "MyClassLongerName":"OtherObfuscation1"], exportTrieObfuscationMap: [:])
    var testObfuscator : MethTypeObfuscator { return MethTypeObfuscator(withMap: testMap) }
    
    func test_shouldNotReplaceClassnameInQuotationMarks_WhenNoMatchingMangling() {
        XCTAssertEqual(#"@"MyNotObfuscatedClassName""#, testObfuscator.generateObfuscatedMethType(methType: #"@"MyNotObfuscatedClassName""#))
    }
    
    func test_shouldNotDestroyBuiltinTypes_WhenNoMatchingMangling() {
        XCTAssertEqual(#"v32@0:8@16Q24"#, testObfuscator.generateObfuscatedMethType(methType: #"v32@0:8@16Q24"#))
        
    }
    
    func test_shouldReplaceClassnameInQuotationMarks() {
        XCTAssertEqual(#"@"OtherObfuscation1""#, testObfuscator.generateObfuscatedMethType(methType: #"@"MyClassLongerName""#))
    }
    
    func test_shouldReplaceClassnameInPointyBracketsAndQuotationMarks() {
        XCTAssertEqual(#"@"<OtherObfuscation1>""#, testObfuscator.generateObfuscatedMethType(methType: #"@"<MyClassLongerName>""#))
    }
    
    func test_shouldReplaceOneClassnameInQuotationMarks() {
        XCTAssertEqual(#"v48@0:8@"ObfClss"16@"NSString"24@"UILocalNotification"32@?<v@?>40"#, testObfuscator.generateObfuscatedMethType(methType: #"v48@0:8@"MyClass"16@"NSString"24@"UILocalNotification"32@?<v@?>40"#))
    }
    
    func test_shouldReplacManyClassnamesInQuotationMarks() {
        XCTAssertEqual(#"v48@0:8@"ObfClss"16@"NSString"24@"OtherObfuscation1"32@?<v@?>40"#, testObfuscator.generateObfuscatedMethType(methType: #"v48@0:8@"MyClass"16@"NSString"24@"MyClassLongerName"32@?<v@?>40"#))
    }
    
    func test_shouldNotReplaceClassnamesInMach_WhenNoMatchingMangling() {
        //Given
        var sut = try! Image.load(url: URL.machoMacExecutable)
        
        //Prepare test obfuscation configuration satisfying requirements of replaceSymbols
        let emptyTrie = Trie(exportsSymbol: false, labelRange: 0..<0, label: [], children: [])
        let firstImportEntry = sut.machs[0].importStack![0]
        let symbolDylib = sut.machs[0].dylibs[firstImportEntry.dylibOrdinal - 1]
        
        let map = SymbolManglingMap(selectors: [:], classNames: testMap.classNames, exportTrieObfuscationMap: [
            URL.machoMacExecutable: [
                sut.machs[0].cpu.asCpuId:
                    (unobfuscated: emptyTrie,
                     obfuscated: emptyTrie)]
            ])
        var paths = ObfuscationPaths()
        paths.resolvedDylibMapPerImageURL = [URL.machoMacExecutable:[symbolDylib: URL(fileURLWithPath: "/tmp/testlib")]]
        
        //When
        sut.replaceSymbols(withMap: map, paths: paths)
        
        //Then
        XCTAssertEqual(["v24@0:8@16", "@16@0:8"], sut.machs[0].methTypes)
    }
}
