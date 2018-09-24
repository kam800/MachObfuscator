import XCTest

class Mach_Loading_MachoMac_Tests: XCTestCase {

    let expectedDylibs = [
        "@rpath/SampleMacAppViewModel.framework/Versions/A/SampleMacAppViewModel",
        "@rpath/SampleMacAppModel.framework/Versions/A/SampleMacAppModel",
        "/System/Library/Frameworks/Foundation.framework/Versions/C/Foundation",
        "/usr/lib/libobjc.A.dylib",
        "/usr/lib/libSystem.B.dylib",
        "/System/Library/Frameworks/AppKit.framework/Versions/C/AppKit",
        "@rpath/libswiftAppKit.dylib",
        "@rpath/libswiftCore.dylib",
        "@rpath/libswiftCoreData.dylib",
        "@rpath/libswiftCoreFoundation.dylib",
        "@rpath/libswiftCoreGraphics.dylib",
        "@rpath/libswiftCoreImage.dylib",
        "@rpath/libswiftDarwin.dylib",
        "@rpath/libswiftDispatch.dylib",
        "@rpath/libswiftFoundation.dylib",
        "@rpath/libswiftIOKit.dylib",
        "@rpath/libswiftMetal.dylib",
        "@rpath/libswiftObjectiveC.dylib",
        "@rpath/libswiftQuartzCore.dylib",
        "@rpath/libswiftXPC.dylib"
    ]

    let expectedSegments: [Mach.Segment] = [
        Mach.Segment(name: "__PAGEZERO", sections: []),
        Mach.Segment(name: "__TEXT", sections: [
            Mach.Section(name: "__text", range: 7344..<11328),
            Mach.Section(name: "__stubs", range: 11328..<11454),
            Mach.Section(name: "__stub_helper", range: 11456..<11682),
            Mach.Section(name: "__objc_classname", range: 11682..<11694),
            Mach.Section(name: "__const", range: 11696..<12066),
            Mach.Section(name: "__cstring", range: 12080..<13554),
            Mach.Section(name: "__objc_methname", range: 13554..<15251),
            Mach.Section(name: "__swift3_typeref", range: 15264..<15608),
            Mach.Section(name: "__swift3_reflstr", range: 15608..<15631),
            Mach.Section(name: "__swift3_fieldmd", range: 15632..<15720),
            Mach.Section(name: "__swift3_assocty", range: 15720..<15768),
            Mach.Section(name: "__swift2_proto", range: 15768..<15832),
            Mach.Section(name: "__unwind_info", range: 15832..<16104),
            Mach.Section(name: "__eh_frame", range: 16104..<16376)
        ]),
        Mach.Segment(name: "__DATA", sections: [
            Mach.Section(name: "__nl_symbol_ptr", range: 16384..<16400),
            Mach.Section(name: "__got", range: 16400..<16504),
            Mach.Section(name: "__la_symbol_ptr", range: 16504..<16672),
            Mach.Section(name: "__const", range: 16672..<16680),
            Mach.Section(name: "__objc_classlist", range: 16680..<16704),
            Mach.Section(name: "__objc_protolist", range: 16704..<16720),
            Mach.Section(name: "__objc_imageinfo", range: 16720..<16728),
            Mach.Section(name: "__objc_const", range: 16728..<19976),
            Mach.Section(name: "__objc_selrefs", range: 19976..<20024),
            Mach.Section(name: "__objc_protorefs", range: 20024..<20040),
            Mach.Section(name: "__objc_classrefs", range: 20040..<20064),
            Mach.Section(name: "__objc_data", range: 20064..<20416),
            Mach.Section(name: "__data", range: 20416..<20904),
            Mach.Section(name: "__bss", range: 0..<24)
        ]),
        Mach.Segment(name: "__LINKEDIT", sections: [])
    ]

    let expectedSymtab = Mach.Symtab(offser: 27184,
                                     numberOfSymbols: 400,
                                     stringTableRange: 33812..<44932)

    let expectedDyldInfo = Mach.DyldInfo(bind: 24808..<26232,
                                         weakBind: 0..<0,
                                         lazyBind: 26232..<27072,
                                         exportRange: 27072..<27120)

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
        XCTAssertEqual(mach.segments.count, 4)
        XCTAssertEqual(mach.segments, expectedSegments)
        XCTAssertEqual(mach.symtab, expectedSymtab)
        XCTAssertEqual(mach.dyldInfo, expectedDyldInfo)
    }
}
