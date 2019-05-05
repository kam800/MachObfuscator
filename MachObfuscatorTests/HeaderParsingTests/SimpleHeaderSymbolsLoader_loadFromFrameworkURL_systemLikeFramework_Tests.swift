import XCTest

class SimpleHeaderSymbolsLoader_loadFromFrameworkURL_systemLikeFramework_Tests: XCTestCase {

    var header: HeaderSymbols!

    override func setUp() {
        super.setUp()

        let sut = SimpleHeaderSymbolsLoader()
        header = try! sut.load(forFrameworkURL: URL.systemLikeFramework)
    }

    override func tearDown() {
        header = nil

        super.tearDown()
    }

    func test_shouldParseAllClasses() {
        let expectedClassNames: Set<String> = [
            "UIApplication",
            "UIUserNotificationSettings",
            "UIApplicationDelegate"
        ]
        XCTAssertEqual(header.classNames, expectedClassNames)
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
            "application:handleActionWithIdentifier:forLocalNotification:completionHandler:"
        ]
        XCTAssertEqual(header.selectors, expectedSelectors)
    }
}
