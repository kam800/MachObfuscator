@testable import App
import XCTest

class Mach_Loading_MachoMac_Tests: XCTestCase {
    let expectedDylibs = ["@rpath/SampleMacAppViewModel.framework/Versions/A/SampleMacAppViewModel", "@rpath/SampleMacAppModel.framework/Versions/A/SampleMacAppModel", "/System/Library/Frameworks/Foundation.framework/Versions/C/Foundation", "/usr/lib/libobjc.A.dylib", "/usr/lib/libSystem.B.dylib", "/System/Library/Frameworks/AppKit.framework/Versions/C/AppKit", "/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation", "@rpath/libswiftAppKit.dylib", "@rpath/libswiftCore.dylib", "@rpath/libswiftCoreData.dylib", "@rpath/libswiftCoreFoundation.dylib", "@rpath/libswiftCoreGraphics.dylib", "@rpath/libswiftCoreImage.dylib", "@rpath/libswiftDarwin.dylib", "@rpath/libswiftDispatch.dylib", "@rpath/libswiftFoundation.dylib", "@rpath/libswiftIOKit.dylib", "@rpath/libswiftMetal.dylib", "@rpath/libswiftObjectiveC.dylib", "@rpath/libswiftQuartzCore.dylib", "@rpath/libswiftXPC.dylib"]

    let expectedPropertyNames = ["additionalDynamicProperty", "dynamicSampleProperty"]

    let expectedSegments: [Mach.Segment] = [App.Mach.Segment(name: "__PAGEZERO", vmRange: 0 ..< 4_294_967_296, fileRange: 0 ..< 0, sections: []), App.Mach.Segment(name: "__TEXT", vmRange: 4_294_967_296 ..< 4_294_983_680, fileRange: 0 ..< 16384, sections: [App.Mach.Section(name: "__text", range: 5328 ..< 11066), App.Mach.Section(name: "__stubs", range: 11066 ..< 11300), App.Mach.Section(name: "__stub_helper", range: 11300 ..< 11706), App.Mach.Section(name: "__objc_classname", range: 11706 ..< 11722), App.Mach.Section(name: "__cstring", range: 11728 ..< 13538), App.Mach.Section(name: "__objc_methname", range: 13538 ..< 15329), App.Mach.Section(name: "__objc_methtype", range: 15329 ..< 15348), App.Mach.Section(name: "__const", range: 15352 ..< 15752), App.Mach.Section(name: "__swift4_typeref", range: 15752 ..< 15961), App.Mach.Section(name: "__swift4_reflstr", range: 15961 ..< 16019), App.Mach.Section(name: "__swift4_fieldmd", range: 16020 ..< 16136), App.Mach.Section(name: "__swift4_assocty", range: 16136 ..< 16184), App.Mach.Section(name: "__swift4_proto", range: 16184 ..< 16212), App.Mach.Section(name: "__swift4_types", range: 16212 ..< 16224), App.Mach.Section(name: "__unwind_info", range: 16224 ..< 16380)]), App.Mach.Segment(name: "__DATA", vmRange: 4_294_983_680 ..< 4_294_991_872, fileRange: 16384 ..< 24576, sections: [App.Mach.Section(name: "__nl_symbol_ptr", range: 16384 ..< 16400), App.Mach.Section(name: "__got", range: 16400 ..< 16560), App.Mach.Section(name: "__la_symbol_ptr", range: 16560 ..< 16872), App.Mach.Section(name: "__const", range: 16872 ..< 17336), App.Mach.Section(name: "__cfstring", range: 17336 ..< 17368), App.Mach.Section(name: "__objc_classlist", range: 17368 ..< 17392), App.Mach.Section(name: "__objc_catlist", range: 17392 ..< 17392), App.Mach.Section(name: "__objc_protolist", range: 17392 ..< 17408), App.Mach.Section(name: "__objc_imageinfo", range: 17408 ..< 17416), App.Mach.Section(name: "__objc_const", range: 17416 ..< 20808), App.Mach.Section(name: "__objc_selrefs", range: 20808 ..< 20856), App.Mach.Section(name: "__objc_protorefs", range: 20856 ..< 20872), App.Mach.Section(name: "__objc_classrefs", range: 20872 ..< 20912), App.Mach.Section(name: "__objc_data", range: 20912 ..< 21264), App.Mach.Section(name: "__data", range: 21264 ..< 21488), App.Mach.Section(name: "__bss", range: 0 ..< 784)]), App.Mach.Segment(name: "__LINKEDIT", vmRange: 4_294_991_872 ..< 4_295_045_120, fileRange: 24576 ..< 77248, sections: [])]

    let expectedSymtab = App.Mach.Symtab(offser: 29496, numberOfSymbols: 634, stringTableRange: 40040 ..< 58040)

    let expectedDyldInfo = App.Mach.DyldInfo(bind: 24824 ..< 26600, weakBind: 0 ..< 0, lazyBind: 26600 ..< 28520, exportRange: 28520 ..< 29416)

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
        XCTAssertEqual(mach.rpaths, ["@executable_path/../Frameworks"])
        XCTAssertEqual(mach.dylibs, expectedDylibs)
        XCTAssertEqual(mach.dynamicPropertyNames, expectedPropertyNames)
        XCTAssertEqual(mach.segments.count, 4)
        XCTAssertEqual(mach.segments, expectedSegments)
        XCTAssertEqual(mach.symtab, expectedSymtab)
        XCTAssertEqual(mach.dyldInfo, expectedDyldInfo)
    }
}
