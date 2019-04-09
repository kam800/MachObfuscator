import XCTest

class Mach_Loading_MachoMac_Tests: XCTestCase {

    let expectedDylibs = ["@rpath/SampleMacAppViewModel.framework/Versions/A/SampleMacAppViewModel", "@rpath/SampleMacAppModel.framework/Versions/A/SampleMacAppModel", "/System/Library/Frameworks/Foundation.framework/Versions/C/Foundation", "/usr/lib/libobjc.A.dylib", "/usr/lib/libSystem.B.dylib", "/System/Library/Frameworks/AppKit.framework/Versions/C/AppKit", "/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation", "@rpath/libswiftAppKit.dylib", "@rpath/libswiftCore.dylib", "@rpath/libswiftCoreData.dylib", "@rpath/libswiftCoreFoundation.dylib", "@rpath/libswiftCoreGraphics.dylib", "@rpath/libswiftCoreImage.dylib", "@rpath/libswiftDarwin.dylib", "@rpath/libswiftDispatch.dylib", "@rpath/libswiftFoundation.dylib", "@rpath/libswiftIOKit.dylib", "@rpath/libswiftMetal.dylib", "@rpath/libswiftObjectiveC.dylib", "@rpath/libswiftQuartzCore.dylib", "@rpath/libswiftXPC.dylib"]

    let expectedPropertyNames = ["additionalDynamicProperty", "dynamicSampleProperty"]

    let expectedSegments: [Mach.Segment] = [MachObfuscatorTests.Mach.Segment(name: "__PAGEZERO", vmRange: 0..<4294967296, fileRange: 0..<0, sections: []), MachObfuscatorTests.Mach.Segment(name: "__TEXT", vmRange: 4294967296..<4294983680, fileRange: 0..<16384, sections: [MachObfuscatorTests.Mach.Section(name: "__text", range: 5328..<11066), MachObfuscatorTests.Mach.Section(name: "__stubs", range: 11066..<11300), MachObfuscatorTests.Mach.Section(name: "__stub_helper", range: 11300..<11706), MachObfuscatorTests.Mach.Section(name: "__objc_classname", range: 11706..<11722), MachObfuscatorTests.Mach.Section(name: "__cstring", range: 11728..<13538), MachObfuscatorTests.Mach.Section(name: "__objc_methname", range: 13538..<15329), MachObfuscatorTests.Mach.Section(name: "__objc_methtype", range: 15329..<15348), MachObfuscatorTests.Mach.Section(name: "__const", range: 15352..<15752), MachObfuscatorTests.Mach.Section(name: "__swift4_typeref", range: 15752..<15961), MachObfuscatorTests.Mach.Section(name: "__swift4_reflstr", range: 15961..<16019), MachObfuscatorTests.Mach.Section(name: "__swift4_fieldmd", range: 16020..<16136), MachObfuscatorTests.Mach.Section(name: "__swift4_assocty", range: 16136..<16184), MachObfuscatorTests.Mach.Section(name: "__swift4_proto", range: 16184..<16212), MachObfuscatorTests.Mach.Section(name: "__swift4_types", range: 16212..<16224), MachObfuscatorTests.Mach.Section(name: "__unwind_info", range: 16224..<16380)]), MachObfuscatorTests.Mach.Segment(name: "__DATA", vmRange: 4294983680..<4294991872, fileRange: 16384..<24576, sections: [MachObfuscatorTests.Mach.Section(name: "__nl_symbol_ptr", range: 16384..<16400), MachObfuscatorTests.Mach.Section(name: "__got", range: 16400..<16560), MachObfuscatorTests.Mach.Section(name: "__la_symbol_ptr", range: 16560..<16872), MachObfuscatorTests.Mach.Section(name: "__const", range: 16872..<17336), MachObfuscatorTests.Mach.Section(name: "__cfstring", range: 17336..<17368), MachObfuscatorTests.Mach.Section(name: "__objc_classlist", range: 17368..<17392), MachObfuscatorTests.Mach.Section(name: "__objc_catlist", range: 17392..<17392), MachObfuscatorTests.Mach.Section(name: "__objc_protolist", range: 17392..<17408), MachObfuscatorTests.Mach.Section(name: "__objc_imageinfo", range: 17408..<17416), MachObfuscatorTests.Mach.Section(name: "__objc_const", range: 17416..<20808), MachObfuscatorTests.Mach.Section(name: "__objc_selrefs", range: 20808..<20856), MachObfuscatorTests.Mach.Section(name: "__objc_protorefs", range: 20856..<20872), MachObfuscatorTests.Mach.Section(name: "__objc_classrefs", range: 20872..<20912), MachObfuscatorTests.Mach.Section(name: "__objc_data", range: 20912..<21264), MachObfuscatorTests.Mach.Section(name: "__data", range: 21264..<21488), MachObfuscatorTests.Mach.Section(name: "__bss", range: 0..<784)]), MachObfuscatorTests.Mach.Segment(name: "__LINKEDIT", vmRange: 4294991872..<4295045120, fileRange: 24576..<77248, sections: [])]

    let expectedSymtab = MachObfuscatorTests.Mach.Symtab(offser: 29496, numberOfSymbols: 634, stringTableRange: 40040..<58040)

    let expectedDyldInfo = MachObfuscatorTests.Mach.DyldInfo(bind: 24824..<26600, weakBind: 0..<0, lazyBind: 26600..<28520, exportRange: 28520..<29416)

    let sut = try! Image.load(url: URL.machoMacExecutable)

    func test_shouldLoadAllStoredProperties() {
        XCTAssertEqual(sut.url, URL.machoMacExecutable)
        guard case let .mach(mach) = sut.contents else {
            XCTFail("Unexpected contents")
            return
        }
        XCTAssertEqual(mach.data, try! Data(contentsOf: URL.machoMacExecutable))
        XCTAssertEqual(mach.type, .executable)
        XCTAssertEqual(mach.platform, .macos)
        XCTAssertEqual(mach.rpaths, [ "@executable_path/../Frameworks" ])
        XCTAssertEqual(mach.dylibs, expectedDylibs)
        XCTAssertEqual(mach.dynamicPropertyNames, expectedPropertyNames)
        XCTAssertEqual(mach.segments.count, 4)
        XCTAssertEqual(mach.segments, expectedSegments)
        XCTAssertEqual(mach.symtab, expectedSymtab)
        XCTAssertEqual(mach.dyldInfo, expectedDyldInfo)
    }
}
