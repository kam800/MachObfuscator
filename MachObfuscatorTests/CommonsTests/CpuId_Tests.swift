import XCTest

class CpuId_Tests: XCTestCase {
    func test_shouldConcatenateCpuTypeAndSubtype() {
        // Given
        let cpu = Mach.Cpu(type: 0x1234_5678, subtype: 0x789A_BCDE)

        // Expect
        XCTAssertEqual(cpu.asCpuId,
                       0x1234_5678_789A_BCDE)
    }
}
