import XCTest

class NibPlist_Nib_Tests: NibModifying_TestsBase {

    override func setUp() {
        super.setUp()
        createSut(type: NibPlist.self, fromURL: URL.macNib)
    }

    func test_selectors_shouldReturnAllOutletsAndActions() {
        let expectedSelectors = [
            "actionButton",
            "titleLabel",
            "nextKeyView",
            "nextKeyView",
            "actionWasTapped:"
        ]
        XCTAssertEqual(sut.selectors.sorted(),
                       expectedSelectors.sorted())
    }

    func test_classNames_shouldReturnAllClassNames() {
        let expectedClassNames = [
            "NSApplication",
            "NSObject",
            "_TtC19MachObfuscatorTests7MacView",
            "CustomObjCButton"
        ]
        XCTAssertEqual(sut.classNames.sorted(),
                       expectedClassNames.sorted())
    }

    func test_modifySelectors_shouldChangeOnlyMatchingOutletsAndActions() {
        // When
        sut.modifySelectors(withMapping: [
            "nextKeyView" : "nkv",
            "noSuch" : "selector",
            "actionWasTapped:" : "memoryMonitor"
        ])

        // Then
        sut.save()
        sut = NibPlist.load(from: sutURL)
        let expectedSelectors = [
            "actionButton",
            "titleLabel",
            "nkv",
            "nkv",
            "memoryMonitor"
        ]
        XCTAssertEqual(sut.selectors.sorted(),
                       expectedSelectors.sorted())
    }

    func test_modifyClassNames_shouldChangeOnlyMatchingClasses() {
        // When
        sut.modifyClassNames(withMapping: [
            "_TtC19MachObfuscatorTests7MacView" : "foo",
            "noSuch" : "class"
        ])

        // Then
        sut.save()
        sut = NibPlist.load(from: sutURL)
        let expectedClassNames = [
            "NSApplication",
            "NSObject",
            "foo",
            "CustomObjCButton"
        ]
        XCTAssertEqual(sut.classNames.sorted(),
                       expectedClassNames.sorted())
    }
}
