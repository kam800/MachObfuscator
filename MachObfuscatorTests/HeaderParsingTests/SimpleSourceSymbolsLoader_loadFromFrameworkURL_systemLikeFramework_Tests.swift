import XCTest

class SimpleSourceSymbolsLoader_loadFromFrameworkURL_systemLikeFramework_Tests: XCTestCase {
    var symbols: ObjectSymbols!

    override func setUp() {
        super.setUp()

        let sut = SimpleSourceSymbolsLoader()
        symbols = try! sut.load(from: .systemLikeFramework)
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
        ]
        XCTAssertEqual(symbols.selectors, expectedSelectors)
    }
}
