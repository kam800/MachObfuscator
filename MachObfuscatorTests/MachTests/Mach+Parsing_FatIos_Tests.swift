import XCTest

class Mach_Parsing_FatIos_Tests: XCTestCase {
    let expectedSelectors = ["application:continueUserActivity:restorationHandler:", "isMemberOfClass:", "setText:", "setWindow:", "application:viewControllerWithRestorationIdentifierPath:coder:", "zone", "superclass", "viewDidLoad", "application:willEncodeRestorableStateWithCoder:", "didTapIncrement:", "application:willFinishLaunchingWithOptions:", "applicationWillEnterForeground:", "application:didDecodeRestorableStateWithCoder:", "applicationWillTerminate:", "application:shouldRestoreApplicationState:", "initWithCoder:", "application:supportedInterfaceOrientationsForWindow:", "autorelease", "respondsToSelector:", "applicationDidBecomeActive:", "application:didFailToRegisterForRemoteNotificationsWithError:", "performSelector:", "isProxy", "setAdditionalNonDynamicProperty:", "setCounterLabel:", "applicationSignificantTimeChange:", "applicationDidReceiveMemoryWarning:", "dealloc", "application:didReceiveLocalNotification:", "additionalNonDynamicProperty", "application:handleActionWithIdentifier:forRemoteNotification:withResponseInfo:completionHandler:", "init", "application:performActionForShortcutItem:completionHandler:", "applicationProtectedDataDidBecomeAvailable:", "application:didFailToContinueUserActivityWithType:error:", "application:openURL:sourceApplication:annotation:", "application:openURL:options:", "application:handleOpenURL:", "application:didRegisterForRemoteNotificationsWithDeviceToken:", "application:didReceiveRemoteNotification:", "application:willContinueUserActivityWithType:", "application:didUpdateUserActivity:", "isEqual:", "conformsToProtocol:", "release", "application:shouldAllowExtensionPointIdentifier:", "application:willChangeStatusBarOrientation:duration:", ".cxx_destruct", "application:handleWatchKitExtensionRequest:reply:", "hash", "application:handleActionWithIdentifier:forLocalNotification:completionHandler:", "application:didChangeStatusBarOrientation:", "applicationDidEnterBackground:", "class", "counterLabel", "application:didFinishLaunchingWithOptions:", "applicationWillResignActive:", "application:didChangeStatusBarFrame:", "performSelector:withObject:", "debugDescription", "applicationShouldRequestHealthAuthorization:", "self", "applicationProtectedDataWillBecomeUnavailable:", "retain", "applicationDidFinishLaunching:", "application:handleActionWithIdentifier:forRemoteNotification:completionHandler:", "application:handleActionWithIdentifier:forLocalNotification:withResponseInfo:completionHandler:", "application:didReceiveRemoteNotification:fetchCompletionHandler:", "application:handleEventsForBackgroundURLSession:completionHandler:", "retainCount", "description", "window", "application:performFetchWithCompletionHandler:", "application:didRegisterUserNotificationSettings:", "initWithNibName:bundle:", "application:shouldSaveApplicationState:", "application:willChangeStatusBarFrame:", "performSelector:withObject:withObject:", "isKindOfClass:"]

    let expectedClassNames = ["SampleClass", "Cat"]

    let expectedCstrings = ["T@\"NSString\",&,N", "Unexpectedly found nil while unwrapping an Optional value", "i8@0:4", "T@\"UIWindow\",N,&", "@?", "v16@0:4@\"UIApplication\"8@\"UIUserNotificationSettings\"12", "v16@0:4@\"UIApplication\"8@\"UILocalNotification\"12", "v28@0:4@\"UIApplication\"8@\"NSString\"12@\"UILocalNotification\"16@\"NSDictionary\"20@?<v@?>24", "I16@0:4@\"UIApplication\"8@\"UIWindow\"12", "v20@0:4@\"UIApplication\"8@\"NSString\"12@\"NSError\"16", "v8@0:4", "v16@0:4@\"UIApplication\"8@?<v@?I>12", "@\"UIViewController\"20@0:4@\"UIApplication\"8@\"NSArray\"12@\"NSCoder\"16", "c12@0:4@8", "dynamicSampleProperty", "_TtC12SampleIosApp14ViewController", "@8@0:4", "NSObject", "^@20@0:4:8@12@16", "c8@0:4", "c20@0:4@\"UIApplication\"8@\"NSURL\"12@\"NSDictionary\"16", "v16@0:4@\"UIApplication\"8@\"NSError\"12", "v20@0:4@\"UIApplication\"8@\"NSDictionary\"12@?<v@?I>16", "c20@0:4@8@12@?16", "c12@0:4@\"Protocol\"8", "v28@0:4@8{CGRect={CGPoint=ff}{CGSize=ff}}12", "v16@0:4@\"UIApplication\"8@\"NSDictionary\"12", "hash", "T@\"UIWindow\",N,&,Vwindow", "v12@0:4@8", "viewModel", "v20@0:4@\"UIApplication\"8@\"NSString\"12@?<v@?>16", "c16@0:4@\"UIApplication\"8@\"NSString\"12", "T@\"NSString\",&,D,N", "^@16@0:4:8@12", "@12@0:4@8", "^@12@0:4:8", "/Users/kamil.borzym/prv/src/MachObfuscator/MachObfuscatorTests/SampleAppSources/SampleIosApp/SampleIosApp/ViewController.swift", "v16@0:4@\"UIApplication\"8i12", "Fatal error", "c16@0:4@\"UIApplication\"8@\"NSCoder\"12", "v16@0:4@8@12", "@20@0:4@8@12@16", "additionalNonDynamicProperty", "@\"UIWindow\"8@0:4", "counterLabel", "v12@0:4@\"UIWindow\"8", "Ti,N,R", "T@\"NSString\",N,R", "UIApplicationDelegate", "T@\"UILabel\",N,W,VcounterLabel", "_TtC12SampleIosApp11AppDelegate", "additionalDynamicProperty", "v24@0:4@\"UIApplication\"8@\"NSString\"12@\"NSDictionary\"16@?<v@?>20", "v16@0:4@\"UIApplication\"8@\"NSUserActivity\"12", "c16@0:4@\"UIApplication\"8@\"NSDictionary\"12", "window", "c20@0:4@8@12@16", "v20@0:4@8@12@16", "test", "v16@0:4@\"UIApplication\"8@\"NSData\"12", "v16@0:4@\"UIApplication\"8@\"NSCoder\"12", "v20@0:4@8@12@?16", "c12@0:4:8", "v16@0:4@8@?12", "v24@0:4@\"UIApplication\"8i12d16", "v12@0:4@\"UIApplication\"8", "c20@0:4@\"UIApplication\"8@\"NSUserActivity\"12@?<v@?@\"NSArray\">16", "#8@0:4", "description", "@16@0:4@8@12", "v24@0:4@8@12@16@?20", "c16@0:4@8@12", "I16@0:4@8@12", "debugDescription", "v28@0:4@8@12@16@20@?24", "v28@0:4@\"UIApplication\"8{CGRect={CGPoint=ff}{CGSize=ff}}12", "v20@0:4@\"UIApplication\"8@\"UIApplicationShortcutItem\"12@?<v@?c>16", "v24@0:4@\"UIApplication\"8@\"NSString\"12@\"UILocalNotification\"16@?<v@?>20", "c24@0:4@\"UIApplication\"8@\"NSURL\"12@\"NSString\"16@20", "v16@0:4@8i12", "^v8@0:4", "c24@0:4@8@12@16@20", "v28@0:4@\"UIApplication\"8@\"NSString\"12@\"NSDictionary\"16@\"NSDictionary\"20@?<v@?>24", "T#,N,R", "v24@0:4@8i12d16", "c12@0:4#8", "c16@0:4@\"UIApplication\"8@\"NSURL\"12", "v20@0:4@\"UIApplication\"8@\"NSDictionary\"12@?<v@?@\"NSDictionary\">16", "@\"NSString\"8@0:4", "superclass"]

    let expectedDynamicProperties = ["additionalDynamicProperty", "dynamicSampleProperty"]

    let sut = try! Image.load(url: URL.fatIosExecutable)

    func test_shouldParseEachComputedProperty() {
        guard case let .fat(fat) = sut.contents else {
            XCTFail("Unexpected contents")
            return
        }
        XCTAssertFalse(fat.architectures.isEmpty)
        let mach = fat.architectures[0].mach

        XCTAssertEqual(Set(mach.selectors), Set(expectedSelectors))
        XCTAssertEqual(Set(mach.classNames), Set(expectedClassNames))
        XCTAssertEqual(Set(mach.cstrings), Set(expectedCstrings))
        XCTAssertEqual(Set(mach.dynamicPropertyNames), Set(expectedDynamicProperties))
        XCTAssertEqual(mach.exportedTrie?.children.count, 1)
        XCTAssertEqual(mach.importStack.count, 67)
        // TODO: sample should have some weak bindings
        XCTAssertEqual(mach.importStack.filter { $0.weak }.count, 0)
    }

    func test_shouldNotFailOnEmptyRangeInLoadCommand() {
        guard case let .fat(fat) = sut.contents else {
            XCTFail("Unexpected contents")
            return
        }
        XCTAssertFalse(fat.architectures.isEmpty)
        var mach = fat.architectures[0].mach

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
        XCTAssert(mach.classNames.isEmpty)
        XCTAssert(mach.cstrings.isEmpty)
        XCTAssert(mach.dynamicPropertyNames.isEmpty)
        XCTAssertNil(mach.exportedTrie)
        XCTAssert(mach.importStack.isEmpty)
    }
}
