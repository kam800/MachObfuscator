@testable import App
import XCTest

class Mach_Loading_FatIos_Tests: XCTestCase {
    let expectedDylibs = ["@rpath/libswiftDispatch.dylib", "@rpath/libswiftFoundation.dylib", "@rpath/SampleIosAppModel.framework/SampleIosAppModel", "/System/Library/Frameworks/UIKit.framework/UIKit", "@rpath/libswiftCoreImage.dylib", "/usr/lib/libSystem.B.dylib", "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation", "@rpath/libswiftCore.dylib", "@rpath/libswiftCoreGraphics.dylib", "@rpath/libswiftDarwin.dylib", "@rpath/libswiftCoreFoundation.dylib", "/System/Library/Frameworks/Foundation.framework/Foundation", "@rpath/libswiftUIKit.dylib", "@rpath/libswiftMetal.dylib", "@rpath/SampleIosAppViewModel.framework/SampleIosAppViewModel", "@rpath/libswiftQuartzCore.dylib", "/usr/lib/libobjc.A.dylib", "@rpath/libswiftObjectiveC.dylib"]

    let expectedSegments: [Mach.Segment] = [MachObfuscatorTests.Mach.Segment(name: "__PAGEZERO", vmRange: 0 ..< 16384, fileRange: 0 ..< 0, sections: []), MachObfuscatorTests.Mach.Segment(name: "__TEXT", vmRange: 16384 ..< 49152, fileRange: 0 ..< 32768, sections: [MachObfuscatorTests.Mach.Section(name: "__text", range: 21480 ..< 25740), MachObfuscatorTests.Mach.Section(name: "__picsymbolstub4", range: 25740 ..< 26124), MachObfuscatorTests.Mach.Section(name: "__stub_helper", range: 26124 ..< 26448), MachObfuscatorTests.Mach.Section(name: "__objc_classname", range: 26448 ..< 26464), MachObfuscatorTests.Mach.Section(name: "__cstring", range: 26464 ..< 29537), MachObfuscatorTests.Mach.Section(name: "__objc_methname", range: 29537 ..< 32202), MachObfuscatorTests.Mach.Section(name: "__objc_methtype", range: 32202 ..< 32219), MachObfuscatorTests.Mach.Section(name: "__const", range: 32220 ..< 32464), MachObfuscatorTests.Mach.Section(name: "__swift4_typeref", range: 32464 ..< 32611), MachObfuscatorTests.Mach.Section(name: "__swift4_reflstr", range: 32611 ..< 32641), MachObfuscatorTests.Mach.Section(name: "__swift4_fieldmd", range: 32644 ..< 32744), MachObfuscatorTests.Mach.Section(name: "__swift4_proto", range: 32744 ..< 32748), MachObfuscatorTests.Mach.Section(name: "__swift4_types", range: 32748 ..< 32756)]), MachObfuscatorTests.Mach.Segment(name: "__DATA", vmRange: 49152 ..< 65536, fileRange: 32768 ..< 49152, sections: [MachObfuscatorTests.Mach.Section(name: "__nl_symbol_ptr", range: 32768 ..< 32812), MachObfuscatorTests.Mach.Section(name: "__la_symbol_ptr", range: 32812 ..< 32908), MachObfuscatorTests.Mach.Section(name: "__const", range: 32908 ..< 32972), MachObfuscatorTests.Mach.Section(name: "__cfstring", range: 32972 ..< 32988), MachObfuscatorTests.Mach.Section(name: "__objc_classlist", range: 32988 ..< 33000), MachObfuscatorTests.Mach.Section(name: "__objc_catlist", range: 33000 ..< 33000), MachObfuscatorTests.Mach.Section(name: "__objc_protolist", range: 33000 ..< 33008), MachObfuscatorTests.Mach.Section(name: "__objc_imageinfo", range: 33008 ..< 33016), MachObfuscatorTests.Mach.Section(name: "__objc_const", range: 33016 ..< 35176), MachObfuscatorTests.Mach.Section(name: "__objc_selrefs", range: 35176 ..< 35200), MachObfuscatorTests.Mach.Section(name: "__objc_protorefs", range: 35200 ..< 35208), MachObfuscatorTests.Mach.Section(name: "__objc_classrefs", range: 35208 ..< 35228), MachObfuscatorTests.Mach.Section(name: "__objc_data", range: 35228 ..< 35444), MachObfuscatorTests.Mach.Section(name: "__data", range: 35444 ..< 35500), MachObfuscatorTests.Mach.Section(name: "__bss", range: 0 ..< 8)]), MachObfuscatorTests.Mach.Segment(name: "__LINKEDIT", vmRange: 65536 ..< 114_688, fileRange: 49152 ..< 89728, sections: [])]

    let expectedSymtab = MachObfuscatorTests.Mach.Symtab(offser: 52536, numberOfSymbols: 421, stringTableRange: 57824 ..< 69568)

    let expectedDyldInfo = MachObfuscatorTests.Mach.DyldInfo(bind: 49432 ..< 50592, weakBind: 0 ..< 0, lazyBind: 50592 ..< 51484, exportRange: 51484 ..< 52472)

    let expectedDynamicProperties = ["additionalDynamicProperty", "dynamicSampleProperty"]

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
        XCTAssertEqual(mach.rpaths, ["@executable_path/Frameworks"])
        XCTAssertEqual(Set(mach.dylibs), Set(expectedDylibs))
        XCTAssertEqual(mach.dynamicPropertyNames, expectedDynamicProperties)
        XCTAssertEqual(mach.segments.count, 4)
        XCTAssertEqual(mach.segments, expectedSegments)
        XCTAssertEqual(mach.symtab, expectedSymtab)
        XCTAssertEqual(mach.dyldInfo, expectedDyldInfo)
    }
}
