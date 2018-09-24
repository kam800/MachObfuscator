import XCTest

class Mach_Loading_FatIos_Tests: XCTestCase {

    let expectedDylibs = [
        "@rpath/SampleIosAppModel.framework/SampleIosAppModel",
        "@rpath/SampleIosAppViewModel.framework/SampleIosAppViewModel",
        "/System/Library/Frameworks/Foundation.framework/Foundation",
        "/usr/lib/libobjc.A.dylib",
        "/usr/lib/libSystem.B.dylib",
        "/System/Library/Frameworks/UIKit.framework/UIKit",
        "@rpath/libswiftCore.dylib",
        "@rpath/libswiftCoreFoundation.dylib",
        "@rpath/libswiftCoreGraphics.dylib",
        "@rpath/libswiftCoreImage.dylib",
        "@rpath/libswiftDarwin.dylib",
        "@rpath/libswiftDispatch.dylib",
        "@rpath/libswiftFoundation.dylib",
        "@rpath/libswiftMetal.dylib",
        "@rpath/libswiftObjectiveC.dylib",
        "@rpath/libswiftQuartzCore.dylib",
        "@rpath/libswiftUIKit.dylib"
    ]

    let expectedSegments: [Mach.Segment] = [
        Mach.Segment(name: "__PAGEZERO", sections: []),
        Mach.Segment(name: "__TEXT", sections: [
            Mach.Section(name: "__text", range: 22408..<26072),
            Mach.Section(name: "__picsymbolstub4", range: 26072..<26424),
            Mach.Section(name: "__stub_helper", range: 26424..<26724),
            Mach.Section(name: "__objc_classname", range: 26724..<26736),
            Mach.Section(name: "__cstring", range: 26736..<29473),
            Mach.Section(name: "__objc_methname", range: 29473..<32076),
            Mach.Section(name: "__const", range: 32080..<32380),
            Mach.Section(name: "__swift3_typeref", range: 32384..<32616),
            Mach.Section(name: "__swift3_reflstr", range: 32616..<32646),
            Mach.Section(name: "__swift3_fieldmd", range: 32648..<32748),
            Mach.Section(name: "__swift2_proto", range: 32748..<32764)
        ]),
        Mach.Segment(name: "__DATA", sections: [
            Mach.Section(name: "__nl_symbol_ptr", range: 32768..<32816),
            Mach.Section(name: "__la_symbol_ptr", range: 32816..<32904),
            Mach.Section(name: "__const", range: 32904..<32908),
            Mach.Section(name: "__objc_classlist", range: 32908..<32920),
            Mach.Section(name: "__objc_protolist", range: 32920..<32928),
            Mach.Section(name: "__objc_imageinfo", range: 32928..<32936),
            Mach.Section(name: "__objc_const", range: 32936..<35032),
            Mach.Section(name: "__objc_selrefs", range: 35032..<35056),
            Mach.Section(name: "__objc_protorefs", range: 35056..<35064),
            Mach.Section(name: "__objc_classrefs", range: 35064..<35076),
            Mach.Section(name: "__objc_data", range: 35076..<35292),
            Mach.Section(name: "__data", range: 35292..<35408),
            Mach.Section(name: "__bss", range: 0..<8)
        ]),
        Mach.Segment(name: "__LINKEDIT", sections: [])
    ]

    let expectedSymtab = Mach.Symtab(offser: 51512,
                                     numberOfSymbols: 294,
                                     stringTableRange: 55264..<63832)

    let expectedDyldInfo = Mach.DyldInfo(bind: 49420..<50692,
                                         weakBind: 0..<0,
                                         lazyBind: 50692..<51424,
                                         exportRange: 51424..<51468)

    let sut = try! Image.load(url: URL.fatIosExecutable)

    func test_shouldLoadAllStoredProperties() {
        XCTAssertEqual(sut.url, URL.fatIosExecutable)
        guard case let .fat(fat) = sut.contents else {
            XCTFail("Unexpected contents")
            return
        }
        XCTAssertEqual(fat.data, try! Data(contentsOf: URL.fatIosExecutable))
        XCTAssertEqual(fat.architectures.count, 2)
        let mach = fat.architectures[0].mach
        XCTAssertEqual(mach.type, .executable)
        XCTAssertEqual(mach.platform, .ios)
        XCTAssertEqual(mach.rpaths, [ "@executable_path/Frameworks" ])
        XCTAssertEqual(mach.dylibs, expectedDylibs)
        XCTAssertEqual(mach.segments.count, 4)
        XCTAssertEqual(mach.segments, expectedSegments)
        XCTAssertEqual(mach.symtab, expectedSymtab)
        XCTAssertEqual(mach.dyldInfo, expectedDyldInfo)
    }
}
