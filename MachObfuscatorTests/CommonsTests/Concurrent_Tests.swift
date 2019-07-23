//
//  Concurrent_Tests.swift
//  MachObfuscatorTests
//

import Foundation
import XCTest

class Concurrent_Tests: XCTestCase {
    
    func test_shouldMapEmptyArray() {
        let testArray : [String] = []
        
        XCTAssertEqual(testArray.concurrentMap { $0+" mapped"}, [])
    }
    
    func test_shouldMapAllElementsInCorrectOrder() {
        let testArray = [1,2,3,4,5]
        
        XCTAssertEqual(testArray.concurrentMap { $0+1 }, [2,3,4,5,6])
    }
    
    func test_shouldMapAllElementsInCorrectOrder_WhenProcessingTakesLong() {
        let testArray = [1,2,3,4,5]
        
        XCTAssertEqual(testArray.concurrentMap { val in
            //sleep for 0 to 0.4 seconds
            usleep(UInt32((5-val)*100_000))
            return val+1
        }, [2,3,4,5,6])
    }
    
    func test_shouldCompactMapEmptyArray() {
        let testArray : [String] = []
        
        XCTAssertEqual(testArray.concurrentCompactMap { $0+" mapped"}, [])
    }
    
    func test_shouldCompactMapEmptyArray_WhenNilIsReturned() {
        let testArray = [1,2,3,4,5]
        
        XCTAssertEqual(testArray.concurrentCompactMap { val in
            return val > 2 ? nil : val+1
        }, [2,3])
    }
}
