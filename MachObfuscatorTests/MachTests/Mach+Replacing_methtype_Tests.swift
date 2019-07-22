//
//  Mach+Replacing_methtype_Tests.swift
//  MachObfuscatorTests
//

import XCTest

class Mach_Replacing_methtype_Tests: XCTestCase {
    let testMap = SymbolManglingMap(selectors: [:], classNames: ["MyClass" : "ObfClss", "MyClassLongerName":"OtherObfuscation1"], exportTrieObfuscationMap: [:])
    
    func test_shouldNotReplaceClassnameInQuotationMarks_WhenNoMatchingMangling() {
        XCTAssertEqual(#"@"MyNotObfuscatedClassName""#, Mach.generateObfuscatedMethType(methType: #"@"MyNotObfuscatedClassName""#, withMap: testMap))
    }
    
    func test_shouldNotDestroyBuiltinTypes_WhenNoMatchingMangling() {
        XCTAssertEqual(#"v32@0:8@16Q24"#, Mach.generateObfuscatedMethType(methType: #"v32@0:8@16Q24"#, withMap: testMap))
        
    }
    
    func test_shouldReplaceClassnameInQuotationMarks() {
        XCTAssertEqual(#"@"OtherObfuscation1""#, Mach.generateObfuscatedMethType(methType: #"@"MyClassLongerName""#, withMap: testMap))
    }
    
    func test_shouldReplaceClassnameInPointyBracketsAndQuotationMarks() {
        XCTAssertEqual(#"@"<OtherObfuscation1>""#, Mach.generateObfuscatedMethType(methType: #"@"<MyClassLongerName>""#, withMap: testMap))
    }
    
    func test_shouldReplaceOneClassnameInQuotationMarks() {
        XCTAssertEqual(#"v48@0:8@"ObfClss"16@"NSString"24@"UILocalNotification"32@?<v@?>40"#, Mach.generateObfuscatedMethType(methType: #"v48@0:8@"MyClass"16@"NSString"24@"UILocalNotification"32@?<v@?>40"#, withMap: testMap))
    }
    
    func test_shouldReplacManyClassnamesInQuotationMarks() {
        XCTAssertEqual(#"v48@0:8@"ObfClss"16@"NSString"24@"OtherObfuscation1"32@?<v@?>40"#, Mach.generateObfuscatedMethType(methType: #"v48@0:8@"MyClass"16@"NSString"24@"MyClassLongerName"32@?<v@?>40"#, withMap: testMap))
    }
}
