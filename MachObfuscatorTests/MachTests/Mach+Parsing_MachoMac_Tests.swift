import XCTest

class Mach_Parsing_MachoMac_Tests: XCTestCase {

    let expectedSelectors = [
        "counterLabel", "setCounterLabel:", "viewDidLoad", "didTapIncrement:", "initWithNibName:bundle:", "initWithCoder:", ".cxx_destruct", "setStringValue:", "init", "dealloc", "applicationShouldTerminate:", "application:openURLs:", "application:openFile:", "application:openFiles:", "application:openTempFile:", "applicationShouldOpenUntitledFile:", "applicationOpenUntitledFile:", "application:openFileWithoutUI:", "application:printFile:", "application:printFiles:withSettings:showPrintPanels:", "applicationShouldTerminateAfterLastWindowClosed:", "applicationShouldHandleReopen:hasVisibleWindows:", "applicationDockMenu:", "application:willPresentError:", "application:didRegisterForRemoteNotificationsWithDeviceToken:", "application:didFailToRegisterForRemoteNotificationsWithError:", "application:didReceiveRemoteNotification:", "application:willEncodeRestorableState:", "application:didDecodeRestorableState:", "application:willContinueUserActivityWithType:", "application:continueUserActivity:restorationHandler:", "application:didFailToContinueUserActivityWithType:error:", "application:didUpdateUserActivity:", "applicationWillFinishLaunching:", "applicationDidFinishLaunching:", "applicationWillHide:", "applicationDidHide:", "applicationWillUnhide:", "applicationDidUnhide:", "applicationWillBecomeActive:", "applicationDidBecomeActive:", "applicationWillResignActive:", "applicationDidResignActive:", "applicationWillUpdate:", "applicationDidUpdate:", "applicationWillTerminate:", "applicationDidChangeScreenParameters:", "applicationDidChangeOcclusionState:", "isEqual:", "hash", "superclass", "class", "self", "performSelector:", "performSelector:withObject:", "performSelector:withObject:withObject:", "isProxy", "isKindOfClass:", "isMemberOfClass:", "conformsToProtocol:", "respondsToSelector:", "retain", "release", "autorelease", "retainCount", "zone", "description", "debugDescription"
    ]

    let expectedClassNames = [ "SampleClass" ]

    let expectedCstrings = [ "_TtC12SampleMacApp14ViewController", "v24@0:8@16", "@32@0:8@16@24", "@24@0:8@16", "@?", "viewModel", "counterLabel", "T@\"NSTextField\",N,W,VcounterLabel", "_TtC12SampleMacApp11AppDelegate", "@16@0:8", "NSApplicationDelegate", "Q24@0:8@16", "v32@0:8@16@24", "c32@0:8@16@24", "c24@0:8@16", "Q44@0:8@16@24@32c40", "c28@0:8@16c24", "c40@0:8@16@24@?32", "v40@0:8@16@24@32", "Q24@0:8@\"NSApplication\"16", "v32@0:8@\"NSApplication\"16@\"NSArray\"24", "c32@0:8@\"NSApplication\"16@\"NSString\"24", "c24@0:8@\"NSApplication\"16", "c32@0:8@16@\"NSString\"24", "Q44@0:8@\"NSApplication\"16@\"NSArray\"24@\"NSDictionary\"32c40", "c28@0:8@\"NSApplication\"16c24", "@\"NSMenu\"24@0:8@\"NSApplication\"16", "@\"NSError\"32@0:8@\"NSApplication\"16@\"NSError\"24", "v32@0:8@\"NSApplication\"16@\"NSData\"24", "v32@0:8@\"NSApplication\"16@\"NSError\"24", "v32@0:8@\"NSApplication\"16@\"NSDictionary\"24", "v32@0:8@\"NSApplication\"16@\"NSCoder\"24", "c40@0:8@\"NSApplication\"16@\"NSUserActivity\"24@?<v@?@\"NSArray\">32", "v40@0:8@\"NSApplication\"16@\"NSString\"24@\"NSError\"32", "v32@0:8@\"NSApplication\"16@\"NSUserActivity\"24", "v24@0:8@\"NSNotification\"16", "NSObject", "q16@0:8", "#16@0:8", "^@24@0:8:16", "^@32@0:8:16@24", "^@40@0:8:16@24@32", "c16@0:8", "c24@0:8#16", "c24@0:8:16", "v16@0:8", "^v16@0:8", "hash", "Tq,N,R", "superclass", "T#,N,R", "description", "T@\"NSString\",N,R", "debugDescription", "c24@0:8@\"Protocol\"16", "@\"NSString\"16@0:8"]

    let sut = try! Image.load(url: URL.machoMacExecutable)

    func test_shouldParseEachComputedProperty() {
        guard case let .mach(mach) = sut.contents else {
            XCTFail("Unexpected contents")
            return
        }
        XCTAssertEqual(mach.selectors, expectedSelectors)
        XCTAssertEqual(mach.classNames,expectedClassNames)
        XCTAssertEqual(mach.cstrings, expectedCstrings)
        XCTAssertEqual(mach.exportedTrie?.children.count, 1)
        XCTAssertEqual(mach.importStack?.count, 73)
        // TODO: sample should have some weak bindings
        XCTAssertEqual(mach.importStack?.filter { $0.weak }.count, 0)
    }
}
