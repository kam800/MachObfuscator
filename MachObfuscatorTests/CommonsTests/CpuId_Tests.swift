import XCTest

class CpuId_Tests: XCTestCase {
    func test_shouldConcatenateCpuTypeAndSubtype() {
        // Given
        let cpu = Mach.Cpu(type: 0x12345678, subtype: 0x789abcde)

        // Expect
        XCTAssertEqual(cpu.asCpuId,
                       0x12345678789abcde)
    }
}
