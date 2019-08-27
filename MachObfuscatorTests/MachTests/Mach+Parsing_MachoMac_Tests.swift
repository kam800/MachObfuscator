import XCTest

class Mach_Parsing_MachoMac_Tests: XCTestCase {
    let expectedSelectors = ["applicationWillHide:", "applicationDidUnhide:", "applicationWillTerminate:", "autorelease", "description", "isKindOfClass:", "application:openFileWithoutUI:", "applicationShouldTerminate:", "application:openFile:", "counterLabel", "applicationWillFinishLaunching:", "applicationDidUpdate:", "setStringValue:", "didTapIncrement:", "debugDescription", "setAdditionalNonDynamicProperty:", "application:openTempFile:", "applicationDidChangeScreenParameters:", ".cxx_destruct", "performSelector:withObject:withObject:", "applicationWillUpdate:", "performSelector:withObject:", "applicationShouldHandleReopen:hasVisibleWindows:", "application:printFiles:withSettings:showPrintPanels:", "applicationDidFinishLaunching:", "application:continueUserActivity:restorationHandler:", "release", "applicationWillBecomeActive:", "application:printFile:", "applicationDidHide:", "applicationWillUnhide:", "applicationDidResignActive:", "isMemberOfClass:", "application:didRegisterForRemoteNotificationsWithDeviceToken:", "application:didReceiveRemoteNotification:", "application:willPresentError:", "additionalNonDynamicProperty", "application:didUpdateUserActivity:", "respondsToSelector:", "initWithNibName:bundle:", "zone", "dealloc", "applicationShouldOpenUntitledFile:", "applicationDidChangeOcclusionState:", "hash", "isProxy", "application:delegateHandlesKey:", "application:willContinueUserActivityWithType:", "retainCount", "applicationDidBecomeActive:", "initWithCoder:", "applicationOpenUntitledFile:", "retain", "application:didDecodeRestorableState:", "class", "viewDidLoad", "setCounterLabel:", "applicationShouldTerminateAfterLastWindowClosed:", "applicationWillResignActive:", "superclass", "application:openFiles:", "application:openURLs:", "application:didFailToRegisterForRemoteNotificationsWithError:", "application:willEncodeRestorableState:", "init", "applicationDockMenu:", "application:didFailToContinueUserActivityWithType:error:", "performSelector:", "isEqual:", "self", "conformsToProtocol:"]

    let expectedClassNamesInSecion = ["SampleClass", "Cat"]
    let expectedClassNames = ["NSObject", "NSApplicationDelegate", "SampleClass"]

    let expectedCstrings = ["/Users/kamil.borzym/prv/src/MachObfuscator/MachObfuscatorTests/SampleAppSources/SampleMacApp/SampleMacApp/ViewController.swift", "T@\"NSString\",&,D,N", "c32@0:8@16@24", "c24@0:8:16", "description", "@24@0:8@16", "Q24@0:8@16", "Q44@0:8@16@24@32c40", "v40@0:8@16@24@32", "v32@0:8@\"NSApplication\"16@\"NSError\"24", "v40@0:8@\"NSApplication\"16@\"NSString\"24@\"NSError\"32", "^@24@0:8:16", "counterLabel", "^@32@0:8:16@24", "^@40@0:8:16@24@32", "c40@0:8@\"NSApplication\"16@\"NSUserActivity\"24@?<v@?@\"NSArray\">32", "v32@0:8@16@24", "c16@0:8", "^v16@0:8", "v32@0:8@\"NSApplication\"16@\"NSCoder\"24", "debugDescription", "Q24@0:8@\"NSApplication\"16", "_TtC12SampleMacApp14ViewController", "q16@0:8", "T@\"NSTextField\",N,W,VcounterLabel", "v16@0:8", "viewModel", "Fatal error", "v24@0:8@16", "@\"NSMenu\"24@0:8@\"NSApplication\"16", "dynamicSampleProperty", "c32@0:8@\"NSApplication\"16@\"NSString\"24", "T#,N,R", "T@\"NSString\",&,N", "#16@0:8", "additionalNonDynamicProperty", "Tq,N,R", "additionalDynamicProperty", "c24@0:8@16", "c40@0:8@16@24@?32", "c32@0:8@16@\"NSString\"24", "hash", "T@\"NSString\",N,R", "Unexpectedly found nil while unwrapping an Optional value", "c24@0:8@\"NSApplication\"16", "c24@0:8#16", "@\"NSString\"16@0:8", "v32@0:8@\"NSApplication\"16@\"NSDictionary\"24", "c28@0:8@16c24", "superclass", "@16@0:8", "v24@0:8@\"NSNotification\"16", "test", "c28@0:8@\"NSApplication\"16c24", "v32@0:8@\"NSApplication\"16@\"NSData\"24", "@\"NSError\"32@0:8@\"NSApplication\"16@\"NSError\"24", "v32@0:8@\"NSApplication\"16@\"NSArray\"24", "_TtC12SampleMacApp11AppDelegate", "NSApplicationDelegate", "v32@0:8@\"NSApplication\"16@\"NSUserActivity\"24", "c24@0:8@\"Protocol\"16", "Q44@0:8@\"NSApplication\"16@\"NSArray\"24@\"NSDictionary\"32c40", "@?", "@32@0:8@16@24", "NSObject"]

    let expectedDynamicProperties = ["dynamicSampleProperty", "additionalDynamicProperty"]

    let sut = try! Image.load(url: URL.machoMacExecutable)

    func test_shouldParseEachComputedProperty() {
        guard case let .mach(mach) = sut.contents else {
            XCTFail("Unexpected contents")
            return
        }
        XCTAssertEqual(Set(mach.selectors), Set(expectedSelectors))
        XCTAssertEqual(Set(mach.classNamesInSection), Set(expectedClassNamesInSecion))
        XCTAssertEqual(Set(mach.classNames), Set(expectedClassNames))
        XCTAssertEqual(Set(mach.cstrings), Set(expectedCstrings))
        XCTAssertEqual(Set(mach.dynamicPropertyNames), Set(expectedDynamicProperties))
        XCTAssertEqual(mach.exportedTrie?.children.count, 1)
        XCTAssertEqual(mach.importStack.count, 98)
        // TODO: sample should have some weak bindings
        XCTAssertEqual(mach.importStack.filter { $0.weak }.count, 0)
    }

    func test_shouldNotFailOnEmptyRangeInLoadCommand() {
        guard case var .mach(mach) = sut.contents else {
            XCTFail("Unexpected contents")
            return
        }
        mach.setEmptyRegionFor(section: "__objc_methname", segment: "__TEXT")
        mach.setEmptyRegionFor(section: "__objc_classname", segment: "__TEXT")
        mach.setEmptyRegionFor(section: "__cstring", segment: "__TEXT")
        mach.setEmptyRegionFor(section: "__objc_classlist", segment: "__DATA")
        mach.setEmptyRegionFor(section: "__objc_catlist", segment: "__DATA")
        mach.dyldInfo!.bind = 0 ..< 0
        mach.dyldInfo!.exportRange = 0 ..< 0
        mach.dyldInfo!.lazyBind = 0 ..< 0
        mach.dyldInfo!.weakBind = 0 ..< 0

        XCTAssert(mach.selectors.isEmpty)
        XCTAssert(mach.classNamesInSection.isEmpty)
        XCTAssert(mach.cstrings.isEmpty)
        XCTAssert(mach.dynamicPropertyNames.isEmpty)
        XCTAssertNil(mach.exportedTrie)
        XCTAssert(mach.importStack.isEmpty)
    }
}
