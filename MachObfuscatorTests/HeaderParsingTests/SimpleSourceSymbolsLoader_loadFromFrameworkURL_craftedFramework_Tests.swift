import XCTest

class SimpleSourceSymbolsLoader_loadFromFrameworkURL_craftedFramework_Tests: XCTestCase {
    var symbols: ObjectSymbols!

    override func setUp() {
        super.setUp()

        let sut = SimpleSourceSymbolsLoader()
        symbols = try! sut.load(from: URL.craftedFramework)
    }

    override func tearDown() {
        symbols = nil

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
            "methodWithDeprecationMsg:",
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
            "property3",
        ]

        let expectedSelectors =
            expectedMethods.union(expectedPropertyNames)

        expectedSelectors.forEach {
            XCTAssert(symbols.selectors.contains($0), "Should contain: \($0)")
        }
        let unexpectedSelectors = symbols.selectors.subtracting(expectedSelectors)
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
        XCTAssertEqual(symbols.classNames.symmetricDifference(expectedClassNames), [])
    }
}
