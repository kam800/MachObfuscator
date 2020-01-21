import XCTest

class SimpleSourceSymbolsLoader_loadFromFrameworkURL_systemLikeFramework_Tests: XCTestCase {
    var symbols: ObjectSymbols!

    override func setUp() {
        super.setUp()

        let sut = SimpleSourceSymbolsLoader()
        symbols = try! sut.load(forFrameworkURL: URL.systemLikeFramework)
    }

    override func tearDown() {
        symbols = nil

        super.tearDown()
    }

    func test_shouldParseAllClasses() {
        let expectedClassNames: Set<String> = [
            "UIApplication",
            "UIUserNotificationSettings",
            "UIApplicationDelegate",
            "NSDictionary",
            "NSOrderedSet",
        ]
        XCTAssertEqual(symbols.classNames, expectedClassNames)
    }

    func test_shouldParseAllSelectors() {
        let expectedSelectors: Set<String> = [
            "sharedApplication",
            "delegate",
            "openURL:",
            "canOpenURL:",
            "registerForRemoteNotificationTypes:",
            "applicationDidFinishLaunching:",
            "application:didFinishLaunchingWithOptions:",
            "application:handleActionWithIdentifier:forLocalNotification:completionHandler:",
            // "NSDictionary.h"
            "countByEnumeratingWithState:objects:count:",
            // "NSOrderedSet.h"
            "count",
            "objectAtIndex:",
            "indexOfObject:",
            "init",
            "initWithObjects:count:",
            "initWithCoder:",
        ]
        XCTAssertEqual(symbols.selectors, expectedSelectors)
    }
}
