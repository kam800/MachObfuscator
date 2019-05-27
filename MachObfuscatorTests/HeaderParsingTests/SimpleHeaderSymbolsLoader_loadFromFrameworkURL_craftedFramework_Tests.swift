import XCTest

class SimpleHeaderSymbolsLoader_loadFromFrameworkURL_craftedFramework_Tests: XCTestCase {

    var header: HeaderSymbols!

    override func setUp() {
        super.setUp()

        let sut = SimpleHeaderSymbolsLoader()
        header = try! sut.load(forFrameworkURL: URL.craftedFramework)
    }

    override func tearDown() {
        header = nil

        super.tearDown()
    }

    func test_shouldParseSelectors() {
        let expectedMethods: Set<String> = [
            "instanceMethod",
            "classMethod",
            "methodWithLeadingInset",
            "methodWithLotOfSpaces",
            "methodWithoutSpaces",
            "methodThatReturnsBlock",
            "methodThatReturnsBlock:andTakesArguments:",
            "methodThatReturnsTypedefedBlock",
            "methodThatTakesInt:andString:andVoid:",
            "methodWithMacros",
            "methodWithDeprecationMsg:"
        ]

        let expectedPropertyNames: Set<String> = [
            "intProperty",
            "propertyWithAttributes",
            "propertyWithLotOfSpaces",
            "propertyWithoutSpaces",
            "pointerProperty",
            "blockProperty",
            "typedeffedBlockProperty",
            "propertyWithGenerics",
            "propertyWithMacros",
            "propertyWithDeprecationMsg",
            "property1",
            "property2",
            "property3"
        ]

        let expectedSelectors =
            expectedMethods.union(expectedPropertyNames)

        expectedSelectors.forEach {
            XCTAssert(header.selectors.contains($0), "Should contain: \($0)")
        }
        let unexpectedSelectors = header.selectors.subtracting(expectedSelectors)
        XCTAssertEqual(unexpectedSelectors, [], "Detected unexpected selectors")
    }

    func test_shouldParceClassNames() {
        let expectedClassNames: Set<String> = [
            "InterfaceWithNSObject",
            "RootInterface",
            "ProtocolWithoutConformance",
            "ProtocolWithConformance",
            "SampleClass_ForwardDeclaration",
            "SampleProtocol_ForwardDeclaration",
        ]
        XCTAssertEqual(header.classNames.symmetricDifference(expectedClassNames), [])
    }
}
