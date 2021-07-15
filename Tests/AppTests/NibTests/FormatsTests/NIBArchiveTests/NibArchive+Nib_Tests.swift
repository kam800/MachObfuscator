@testable import App
import XCTest

class NibArchive_Nib_Tests: NibModifying_TestsBase {
    override func setUp() {
        super.setUp()
        createSut(type: NibArchive.self, fromURL: URL.iosNib)
    }

    func test_selectors_shouldReturnAllOutletsAndActions() {
        let expectedSelectors = [
            "actionButton",
            "actionWasTapped:",
            "associatedLabel",
            "titleLabel",
        ]
        XCTAssertEqual(sut.selectors.sorted(),
                       expectedSelectors.sorted())
    }

    func test_classNames_shouldReturnAllClassNames() {
        let expectedClassNames = [
            "CustomObjCButton",
            "_TtC19MachObfuscatorTests7IosView",
        ]
        XCTAssertEqual(sut.classNames.sorted(),
                       expectedClassNames.sorted())
    }

    func test_modifySelectors_shouldChangeOnlyMatchingOutletsAndActions() {
        // When
        sut.modifySelectors(withMapping: [
            "titleLabel": "doneButton",
            "noSuch": "selector",
            "actionWasTapped:": "timerElapsed",
        ])

        // Then
        sut.save()
        sut = NibArchive.load(from: sutURL)
        let expectedSelectors = [
            "actionButton",
            "timerElapsed",
            "associatedLabel",
            "doneButton",
        ]
        XCTAssertEqual(sut.selectors.sorted(),
                       expectedSelectors.sorted())
    }

    func test_modifyClassNames_shouldChangeOnlyMatchingClasses() {
        // When
        sut.modifyClassNames(withMapping: [
            "_TtC19MachObfuscatorTests7IosView": "bar",
            "noSuch": "class",
        ])

        // Then
        sut.save()
        sut = NibArchive.load(from: sutURL)
        let expectedClassNames = [
            "CustomObjCButton",
            "bar",
        ]
        XCTAssertEqual(sut.classNames.sorted(),
                       expectedClassNames.sorted())
    }
}
