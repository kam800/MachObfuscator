import XCTest

class ObfuscationPaths_Building_forAllExecutablesWithDependencies_Tests: XCTestCase {

    let sampleAppURL = "/tmp/SampleApp.app".asURL
    var testRepository: ObfuscationPathsTestRepository! = ObfuscationPathsTestRepository()

    override func setUp() {
        super.setUp()

        testRepository.expectedRoot = sampleAppURL
        addSomeUnrelatedFiles()
    }

    func addSomeUnrelatedFiles() {
        testRepository.addFilePath("/tmp/SampleApp.app/Resources/image1.png")
        testRepository.addFilePath("/tmp/SampleApp.app/Resources/image2.png")
        testRepository.addFilePath("/tmp/SampleApp.app/Info.plist")
        testRepository.addFilePath("/tmp/SampleApp.app/PlugIns/SampleAppExtension.appex/Info.plist")
    }

    func buildSUT() -> ObfuscationPaths {
        return ObfuscationPaths.forAllExecutablesWithDependencies(inDirectory: sampleAppURL,
                                                                  fileRepository: testRepository,
                                                                  dependencyNodeLoader: testRepository)
    }

    func test_shouldCollectAllExecutables() {
        // Given
        let executablePath1 = "/tmp/SampleApp.app/MacOS/SampleApp"
        testRepository.addMachOPath(executablePath1, isExecutable: true)

        let executablePath2 = "/tmp/SampleApp.app/PlugIns/SampleAppExtension.appex/MacOS/SampleApp"
        testRepository.addMachOPath(executablePath2, isExecutable: true)

        // When
        let sut = buildSUT()

        // Then
        XCTAssertEqual(sut.obfuscableImages,
                       [executablePath1.asURL, executablePath2.asURL])
        XCTAssert(sut.resolvedDylibMapPerImageURL[executablePath1.asURL]?.isEmpty ?? false)
        XCTAssert(sut.resolvedDylibMapPerImageURL[executablePath2.asURL]?.isEmpty ?? false)
    }

    // TODO: MachObfuscator should obfuscate all Mach-O in app bundle (unreferenced Mach-Os could be dynamically
    // loaded).
    func test_shouldNotCollectUnreferencedImages() {
        // Given
        let executablePath = "/tmp/SampleApp.app/MacOS/SampleApp"
        testRepository.addMachOPath(executablePath, isExecutable: true)

        let unusedFrameworkPath = "/tmp/SampleApp.app/Frameworks/Frm1.framework/Frm1"
        testRepository.addMachOPath(unusedFrameworkPath, isExecutable: false)

        // When
        let sut = buildSUT()

        // Then
        XCTAssertFalse(sut.obfuscableImages.contains(unusedFrameworkPath.asURL))
        XCTAssert(sut.resolvedDylibMapPerImageURL[executablePath.asURL]?.isEmpty ?? false)
    }

    func test_shouldCollectExecutableDependencies_ByExecutablePathInRpath() {
        // Given
        let executablePath = "/tmp/SampleApp.app/MacOS/SampleApp"
        let dependencyDylibEntry = "@rpath/Frm1.framework/Frm1"
        testRepository.addMachOPath(executablePath,
                                    isExecutable: true,
                                    dylibs: [ dependencyDylibEntry ],
                                    rpaths: [ "@executable_path/../Frameworks" ])

        let dependencyPath = "/tmp/SampleApp.app/Frameworks/Frm1.framework/Frm1"
        testRepository.addMachOPath(dependencyPath, isExecutable: false)

        // When
        let sut = buildSUT()

        // Then
        XCTAssert(sut.obfuscableImages.contains(dependencyPath.asURL))
        XCTAssertEqual(sut.resolvedDylibMapPerImageURL[executablePath.asURL],
                       [ dependencyDylibEntry : dependencyPath.asURL ])
        XCTAssert(sut.resolvedDylibMapPerImageURL[dependencyPath.asURL]?.isEmpty ?? false)
    }

    func test_shouldCollectExecutableDependencies_byLoaderPathInRpath() {
        // Given
        let executablePath = "/tmp/SampleApp.app/MacOS/SampleApp"
        let dependencyDylibEntry = "@rpath/libDep"
        testRepository.addMachOPath(executablePath,
                                    isExecutable: true,
                                    dylibs: [ dependencyDylibEntry ],
                                    rpaths: [ "@loader_path/../Frameworks" ])

        let dependencyPath = "/tmp/SampleApp.app/Frameworks/libDep"
        testRepository.addMachOPath(dependencyPath,
                                    isExecutable: false)

        // When
        let sut = buildSUT()

        // Then
        XCTAssert(sut.obfuscableImages.contains(dependencyPath.asURL))
        XCTAssertEqual(sut.resolvedDylibMapPerImageURL[executablePath.asURL],
                       [ dependencyDylibEntry : dependencyPath.asURL ])
        XCTAssert(sut.resolvedDylibMapPerImageURL[dependencyPath.asURL]?.isEmpty ?? false)
    }

    func test_shouldCollectSubdependencyChain_byLoaderPathInRpath() {
        // Given
        testRepository.addMachOPath("/tmp/SampleApp.app/MacOS/SampleApp",
                                    isExecutable: true,
                                    dylibs: [ "@rpath/lib1" ],
                                    rpaths: [ "@executable_path/../Frameworks" ])

        testRepository.addMachOPath("/tmp/SampleApp.app/Frameworks/lib1",
                                    isExecutable: false,
                                    dylibs: [ "@rpath/lib2" ],
                                    rpaths: [ "@loader_path"])

        let lib2Path = "/tmp/SampleApp.app/Frameworks/lib2"
        let lib3DylibEntry = "@rpath/lib3"
        testRepository.addMachOPath(lib2Path,
                                    isExecutable: false,
                                    dylibs: [ lib3DylibEntry ],
                                    rpaths: [ "@loader_path"])

        let lib3Path = "/tmp/SampleApp.app/Frameworks/lib3"
        let lib4DylibEntry = "@rpath/lib4"
        testRepository.addMachOPath(lib3Path,
                                    isExecutable: false,
                                    dylibs: [ lib4DylibEntry ],
                                    rpaths: [ "@loader_path"])

        let lib4Path = "/tmp/SampleApp.app/Frameworks/lib4"
        testRepository.addMachOPath(lib4Path,
                                    isExecutable: false)

        // When
        let sut = buildSUT()

        // Then
        XCTAssert(sut.obfuscableImages.contains(lib2Path.asURL))
        XCTAssertEqual(sut.resolvedDylibMapPerImageURL[lib2Path.asURL],
                       [ lib3DylibEntry : lib3Path.asURL ])
        XCTAssert(sut.obfuscableImages.contains(lib3Path.asURL))
        XCTAssertEqual(sut.resolvedDylibMapPerImageURL[lib3Path.asURL],
                       [ lib4DylibEntry : lib4Path.asURL ])
        XCTAssert(sut.obfuscableImages.contains(lib4Path.asURL))
        XCTAssert(sut.resolvedDylibMapPerImageURL[lib4Path.asURL]?.isEmpty ?? false)
    }

    func test_shouldCollectSubdependencyChain_byExecutablePathInRpath() {
        // Given
        testRepository.addMachOPath("/tmp/SampleApp.app/MacOS/SampleApp",
                                    isExecutable: true,
                                    dylibs: [ "@rpath/lib1" ],
                                    rpaths: [ "@executable_path/../Frameworks" ])

        testRepository.addMachOPath("/tmp/SampleApp.app/Frameworks/lib1",
                                    isExecutable: false,
                                    dylibs: [ "@rpath/lib2" ],
                                    rpaths: [ "@executable_path/../Frameworks" ])

        let lib2Path = "/tmp/SampleApp.app/Frameworks/lib2"
        let lib3DylibEntry = "@rpath/lib3"
        testRepository.addMachOPath(lib2Path,
                                    isExecutable: false,
                                    dylibs: [ lib3DylibEntry ],
                                    rpaths: [ "@executable_path/../Frameworks" ])

        let lib3Path = "/tmp/SampleApp.app/Frameworks/lib3"
        let lib4DylibEntry = "@rpath/lib4"
        testRepository.addMachOPath(lib3Path,
                                    isExecutable: false,
                                    dylibs: [ lib4DylibEntry ],
                                    rpaths: [ "@executable_path/../Frameworks" ])

        let lib4Path = "/tmp/SampleApp.app/Frameworks/lib4"
        testRepository.addMachOPath(lib4Path,
                                    isExecutable: false)

        // When
        let sut = buildSUT()

        // Then
        XCTAssert(sut.obfuscableImages.contains(lib2Path.asURL))
        XCTAssertEqual(sut.resolvedDylibMapPerImageURL[lib2Path.asURL],
                       [ lib3DylibEntry : lib3Path.asURL ])
        XCTAssert(sut.obfuscableImages.contains(lib3Path.asURL))
        XCTAssertEqual(sut.resolvedDylibMapPerImageURL[lib3Path.asURL],
                       [ lib4DylibEntry : lib4Path.asURL ])
        XCTAssert(sut.obfuscableImages.contains(lib4Path.asURL))
        XCTAssert(sut.resolvedDylibMapPerImageURL[lib4Path.asURL]?.isEmpty ?? false)
    }

    func test_shouldUseLoaderPathAsDefaultRpath() {
        // Given
        testRepository.addMachOPath("/tmp/SampleApp.app/MacOS/SampleApp",
                                    isExecutable: true,
                                    dylibs: [ "@rpath/lib1" ],
                                    rpaths: [ "@executable_path/../Frameworks" ])

        testRepository.addMachOPath("/tmp/SampleApp.app/Frameworks/lib1",
                                    isExecutable: false,
                                    dylibs: [ "@rpath/lib2" ])

        let lib2Path = "/tmp/SampleApp.app/Frameworks/lib2"
        testRepository.addMachOPath(lib2Path,
                                    isExecutable: false)

        // When
        let sut = buildSUT()

        // Then
        XCTAssert(sut.obfuscableImages.contains(lib2Path.asURL))
    }

    func test_shouldCollectNestedSubdependency_ByLoaderPathInRpath() {
        // Given
        testRepository.addMachOPath("/tmp/SampleApp.app/MacOS/SampleApp",
                                    isExecutable: true,
                                    dylibs: [ "@rpath/Frm1.framework/Frm1" ],
                                    rpaths: [ "@executable_path/../Frameworks" ])

        testRepository.addMachOPath("/tmp/SampleApp.app/Frameworks/Frm1.framework/Frm1",
                                    isExecutable: false,
                                    dylibs: [ "@rpath/lib1" ],
                                    rpaths: [ "@loader_path/Frameworks" ])

        let lib1Path = "/tmp/SampleApp.app/Frameworks/Frm1.framework/Frameworks/lib1"
        let lib2DylibEntry = "@rpath/lib2"
        testRepository.addMachOPath(lib1Path,
                                    isExecutable: false,
                                    dylibs: [ lib2DylibEntry ],
                                    rpaths: [ "@loader_path" ])

        let lib2Path = "/tmp/SampleApp.app/Frameworks/Frm1.framework/Frameworks/lib2"
        testRepository.addMachOPath(lib2Path,
                                    isExecutable: false)

        // When
        let sut = buildSUT()

        // Then
        XCTAssert(sut.obfuscableImages.contains(lib1Path.asURL))
        XCTAssertEqual(sut.resolvedDylibMapPerImageURL[lib1Path.asURL],
                       [ lib2DylibEntry : lib2Path.asURL ])
        XCTAssert(sut.obfuscableImages.contains(lib2Path.asURL))
        XCTAssert(sut.resolvedDylibMapPerImageURL[lib2Path.asURL]?.isEmpty ?? false)
    }

    func test_shouldCollectExternalDependencies_AsUnobfuscable_WhenMacOSPlatform() {
        // Given
        let executablePath = "/tmp/SampleApp.app/MacOS/SampleApp"
        let externalDependency1Path = "/usr/lib/libobjc.A.dylib"
        let libDyldEntry = "@rpath/lib"
        let externalFramework = "/MockSystem/Library/Frameworks/AdSupport.framework"
        let externalLibrary = externalFramework + "/AdSupport"
        testRepository.addMachOPath(executablePath,
                                    platform: .macos,
                                    isExecutable: true,
                                    dylibs: [ externalDependency1Path, libDyldEntry ],
                                    rpaths: [ "@executable_path/../Frameworks" ],
                                    cstrings: [ "foo", externalFramework, "bar" ])

        let libPath = "/tmp/SampleApp.app/Frameworks/lib"
        let externalDependency2Path = "/System/Library/Frameworks/AppKit.framework/Versions/C/AppKit"
        testRepository.addMachOPath(libPath,
                                    isExecutable: false,
                                    dylibs: [ externalDependency2Path ])

        testRepository.addMachOPath(externalDependency1Path, isExecutable: false)
        testRepository.addMachOPath(externalDependency2Path, isExecutable: false)
        testRepository.addMachOPath(externalLibrary, isExecutable: false)

        let externalDependency2SDKPath = Paths.macosFrameworksRoot + "/System/Library/Frameworks/AppKit.framework"
        testRepository.addFilePath(externalDependency2SDKPath)

        // When
        let sut = buildSUT()

        // Then
        XCTAssertEqual(sut.unobfuscableDependencies,
                       [ externalDependency1Path.asURL, externalDependency2Path.asURL, externalLibrary.asURL ])
        XCTAssertEqual(sut.resolvedDylibMapPerImageURL[executablePath.asURL],
                       [ libDyldEntry: libPath.asURL,
                         externalDependency1Path: externalDependency1Path.asURL,
                         externalLibrary: externalLibrary.asURL])
        XCTAssertEqual(sut.resolvedDylibMapPerImageURL[libPath.asURL],
                       [ externalDependency2Path: externalDependency2Path.asURL ])
        XCTAssertEqual(sut.systemFrameworks, [ externalDependency2SDKPath.asURL ])
    }

    func test_shouldCollectExternalDependencies_AsUnobfuscable_AndAppendRuntimePrefix_WhenIOSPlatform() {
        // Given
        let executablePath = "/tmp/SampleApp.app/SampleApp"
        let externalDependency1DylibEntry = "/usr/lib/libobjc.A.dylib"
        let libDylibEntry = "@rpath/lib"
        let externalFramework = "/MockSystem/Library/Frameworks/AdSupport.framework"
        let externalLibrary = externalFramework + "/AdSupport"
        testRepository.addMachOPath(executablePath,
                                    platform: .ios,
                                    isExecutable: true,
                                    dylibs: [ externalDependency1DylibEntry, libDylibEntry ],
                                    rpaths: [ "@executable_path/Frameworks" ],
                                    cstrings: [ "foo", externalFramework, "bar" ])

        let libPath = "/tmp/SampleApp.app/Frameworks/lib"
        let externalDependency2DylibEntry = "/System/Library/Frameworks/UIKit.framework/UIKit"
        testRepository.addMachOPath(libPath,
                                    platform: .ios,
                                    isExecutable: false,
                                    dylibs: [ externalDependency2DylibEntry ])

        let runtimePrefixedExternalDependency1Path = "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/usr/lib/libobjc.A.dylib"
        testRepository.addMachOPath(runtimePrefixedExternalDependency1Path, platform: .ios, isExecutable: false)

        let runtimePrefixedExternalDependency2Path = "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/UIKit.framework/UIKit"
        testRepository.addMachOPath(runtimePrefixedExternalDependency2Path, platform: .ios, isExecutable: false)
        let runtimePrefixedExternalLibrary =
            "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/MockSystem/Library/Frameworks/AdSupport.framework/AdSupport"
        testRepository.addMachOPath(runtimePrefixedExternalLibrary, platform: .ios, isExecutable: false)

        let externalFrameworkSDKPath = Paths.iosFrameworksRoot + externalFramework
        testRepository.addFilePath(externalFrameworkSDKPath)
        let externalFramework2SDKPath = Paths.iosFrameworksRoot + "/System/Library/Frameworks/UIKit.framework"
        testRepository.addFilePath(externalFramework2SDKPath)

        // When
        let sut = buildSUT()

        // Then
        XCTAssertEqual(sut.unobfuscableDependencies,
                       [ runtimePrefixedExternalDependency1Path.asURL,
                         runtimePrefixedExternalDependency2Path.asURL,
                         runtimePrefixedExternalLibrary.asURL,
                        ])
        XCTAssertEqual(sut.resolvedDylibMapPerImageURL[executablePath.asURL]?[externalDependency1DylibEntry],
                       runtimePrefixedExternalDependency1Path.asURL)
        XCTAssertEqual(sut.resolvedDylibMapPerImageURL[executablePath.asURL]?[externalLibrary],
                       runtimePrefixedExternalLibrary.asURL)
        XCTAssertEqual(sut.resolvedDylibMapPerImageURL[libPath.asURL]?[externalDependency2DylibEntry],
                       runtimePrefixedExternalDependency2Path.asURL)
        XCTAssertEqual(sut.systemFrameworks, [ externalFrameworkSDKPath.asURL, externalFramework2SDKPath.asURL ])
    }

    func test_shouldCollectSwiftLibraries_AsUnobfuscable() {
        // Given
        let executablePath = "/tmp/SampleApp.app/MacOS/SampleApp"
        let exeDyldEntry1 = "@rpath/lib"
        let exeDyldEntry2 = "@rpath/libswiftMetal.dylib"
        testRepository.addMachOPath(executablePath,
                                    platform: .macos,
                                    isExecutable: true,
                                    dylibs: [ exeDyldEntry1, exeDyldEntry2 ],
                                    rpaths: [ "@executable_path/../Frameworks" ])

        let lib1Path = "/tmp/SampleApp.app/Frameworks/lib"
        let lib1DyldEntry = "@rpath/libswiftFoundation.dylib"
        testRepository.addMachOPath(lib1Path,
                                    isExecutable: false,
                                    dylibs: [ lib1DyldEntry ])

        let lib2Path = "/tmp/SampleApp.app/Frameworks/libswiftFoundation.dylib"
        testRepository.addMachOPath(lib2Path,
                                    isExecutable: false)

        let lib3Path = "/tmp/SampleApp.app/Frameworks/libswiftMetal.dylib"
        let lib3DyldEntry = "@rpath/libswiftCore.dylib"
        testRepository.addMachOPath(lib3Path,
                                    isExecutable: false,
                                    dylibs: [ lib3DyldEntry ])

        let lib4Path = "/tmp/SampleApp.app/Frameworks/libswiftCore.dylib"
        testRepository.addMachOPath(lib4Path,
                                    isExecutable: false,
                                    dylibs: [])

        // When
        let sut = buildSUT()

        // Then
        XCTAssertEqual(sut.unobfuscableDependencies,
                       [ lib2Path.asURL, lib3Path.asURL, lib4Path.asURL ])
        XCTAssertEqual(sut.resolvedDylibMapPerImageURL[executablePath.asURL],
                       [ exeDyldEntry1: lib1Path.asURL,
                         exeDyldEntry2: lib3Path.asURL ])
        XCTAssertEqual(sut.resolvedDylibMapPerImageURL[lib1Path.asURL],
                       [ lib1DyldEntry: lib2Path.asURL ])
        XCTAssertEqual(sut.resolvedDylibMapPerImageURL[lib2Path.asURL],
                       [:])
        XCTAssertEqual(sut.resolvedDylibMapPerImageURL[lib3Path.asURL],
                       [ lib3DyldEntry: lib4Path.asURL])
        XCTAssertEqual(sut.resolvedDylibMapPerImageURL[lib4Path.asURL],
                       [:])
    }

    func test_shouldCollectAllNibs() {
        // Given
        let nib1Path = "/tmp/SampleApp.app/Resources/View1.nib"
        let nib2Path = "/tmp/SampleApp.app/Resources/Bundle.bundle/View2.nib"
        testRepository.addFilePath(nib1Path)
        testRepository.addFilePath(nib2Path)

        // When
        let sut = buildSUT()

        // Then
        XCTAssertEqual(sut.nibs, [ nib1Path.asURL, nib2Path.asURL ])
    }
}
