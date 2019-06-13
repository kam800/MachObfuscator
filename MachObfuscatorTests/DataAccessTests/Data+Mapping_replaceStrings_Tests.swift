import XCTest

class Data_Mapping_replaceStrings_Tests: XCTestCase {


    func test_shouldNotChangeData_whenNoMatchingMapping() {
        // Given
        let data = "string\0".data(using: .utf8)!
        var sut = data

        // When
        sut.replaceStrings(inRange: 0..<data.count, withMapping: [ "str" : "int" ])

        // Then
        XCTAssertEqual(sut, data)
    }

    func test_shouldReplaceString_whenMappingMatches() {
        // Given
        let data = "string\0array\0".data(using: .utf8)!
        var sut = data

        // When
        sut.replaceStrings(inRange: 0..<data.count, withMapping: [ "string" : "double" ])

        // Then
        XCTAssertEqual(sut, "double\0array\0".data(using: .utf8))
    }

    func test_shouldReplaceMultipleStrings() {
        // Given
        let data = "a1\0a2\0\0\0a3\0\0\0\0a5\0a6\0".data(using: .utf8)!
        var sut = data

        let mapping = [ "a1" : "b1",
                        "a3" : "b3",
                        "a6" : "b6" ]

        // When
        sut.replaceStrings(inRange: 0..<data.count, withMapping: mapping)

        // Then
        XCTAssertEqual(sut, "b1\0a2\0\0\0b3\0\0\0\0a5\0b6\0".data(using: .utf8))
    }
    
    
    func test_shouldReplaceStringWithNonasciiCharacters_whenMappingMatches() {
        // Given
        let data = "zażółć:gęślą:jaźń\0array\0".data(using: .utf8)!
        var sut = data
        
        // When
        sut.replaceStrings(inRange: 0..<data.count, withMapping: [ "zażółć:gęślą:jaźń" : "zazzoollccXgeesslaaXjazznn" ])
        
        // Then
        XCTAssertEqual(sut, "zazzoollccXgeesslaaXjazznn\0array\0".data(using: .utf8))
    }
}
