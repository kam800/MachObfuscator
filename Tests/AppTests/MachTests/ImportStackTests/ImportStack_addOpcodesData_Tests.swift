@testable import App
import XCTest

class ImportStack_addOpcodesData_Tests: XCTestCase {
    var sut: ImportStack! = ImportStack()

    func when(opcodes: [UInt8]) {
        sut.add(opcodesData: Data(opcodes), range: 0 ..< opcodes.count, weakly: false)
    }

    func test_shouldSetDylibOrdinalFromImmediateValueOf_SET_DYLIB_ORDINAL_IMM() {
        // Given
        let opcodes = [
            UInt8(BIND_OPCODE_SET_DYLIB_ORDINAL_IMM) | 7,
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x41, 0x00,
            UInt8(BIND_OPCODE_DO_BIND),
        ]

        // When
        when(opcodes: opcodes)

        // Then
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut[0].dylibOrdinal, 7)
    }

    func test_shouldSetDylibOrdinalFromUlebValueOf_SET_DYLIB_ORDINAL_ULEB() {
        // Given
        let opcodes = [
            UInt8(BIND_OPCODE_SET_DYLIB_ORDINAL_ULEB),
            0x80, 0x18, // uleb -> 0x0c00
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x41, 0x00,
            UInt8(BIND_OPCODE_DO_BIND),
        ]

        // When
        when(opcodes: opcodes)

        // Then
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut[0].dylibOrdinal, 0x0C00)
    }

    func test_shouldSetSymbolBytesFromCstringAfter_SET_SYMBOL_TRAILING_FLAGS_IMM() {
        // Given
        let opcodes = [
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM) | 3,
            0x41, 0x48, 0x43, 0x00,
            UInt8(BIND_OPCODE_DO_BIND),
        ]

        // When
        when(opcodes: opcodes)

        // Then
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut[0].symbol, [0x41, 0x48, 0x43])
        XCTAssertEqual(sut[0].symbolRange, 1 ..< 4)
    }

    func test_shouldIgnore_SET_TYPE_IMM() {
        // Given
        let opcodes = [
            UInt8(BIND_OPCODE_SET_TYPE_IMM) | 3,
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x41, 0x00,
            UInt8(BIND_OPCODE_DO_BIND),
        ]

        // When
        when(opcodes: opcodes)

        // Then
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut[0].symbol, [0x41])
    }

    func test_shouldIgnore_SET_ADDEND_SLEB() {
        // Given
        let opcodes = [
            UInt8(BIND_OPCODE_SET_ADDEND_SLEB),
            0x80, 0x01,
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x41, 0x00,
            UInt8(BIND_OPCODE_DO_BIND),
        ]

        // When
        when(opcodes: opcodes)

        // Then
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut[0].symbol, [0x41])
    }

    func test_shouldIgnore_SET_SEGMENT_AND_OFFSET_ULEB() {
        // Given
        let opcodes = [
            UInt8(BIND_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB),
            0x80, 0x01,
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x41, 0x00,
            UInt8(BIND_OPCODE_DO_BIND),
        ]

        // When
        when(opcodes: opcodes)

        // Then
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut[0].symbol, [0x41])
    }

    func test_shouldIgnore_ADD_ADDR_ULEB() {
        // Given
        let opcodes = [
            UInt8(BIND_OPCODE_ADD_ADDR_ULEB),
            0x80, 0x01,
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x41, 0x00,
            UInt8(BIND_OPCODE_DO_BIND),
        ]

        // When
        when(opcodes: opcodes)

        // Then
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut[0].symbol, [0x41])
    }

    func test_shouldBindWith_DO_BIND_ULEB_TIMES_SKIPPING_ULEB() {
        // Given
        let opcodes = [
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x41, 0x00,
            UInt8(BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB),
            0x80, 0x01, // times uleb
            0x80, 0x01, // skipping uleb
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x42, 0x00,
            UInt8(BIND_OPCODE_DO_BIND),
        ]

        // When
        when(opcodes: opcodes)

        // Then
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut[0].symbol, [0x41])
        XCTAssertEqual(sut[1].symbol, [0x42])
    }

    func test_shouldBindWith_DO_BIND_ADD_ADDR_ULEB() {
        // Given
        let opcodes = [
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x41, 0x00,
            UInt8(BIND_OPCODE_DO_BIND_ADD_ADDR_ULEB),
            0x80, 0x01, // add address uleb
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x42, 0x00,
            UInt8(BIND_OPCODE_DO_BIND),
        ]

        // When
        when(opcodes: opcodes)

        // Then
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut[0].symbol, [0x41])
        XCTAssertEqual(sut[1].symbol, [0x42])
    }

    func test_shouldBindWith_DO_BIND_ADD_ADDR_IMM_SCALED() {
        // Given
        let opcodes = [
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x41, 0x00,
            UInt8(BIND_OPCODE_DO_BIND_ADD_ADDR_IMM_SCALED) | 3,
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x42, 0x00,
            UInt8(BIND_OPCODE_DO_BIND),
        ]

        // When
        when(opcodes: opcodes)

        // Then
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut[0].symbol, [0x41])
        XCTAssertEqual(sut[1].symbol, [0x42])
    }

    func test_shouldBindWith_DO_BIND() {
        // Given
        let opcodes = [
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x41, 0x00,
            UInt8(BIND_OPCODE_DO_BIND),
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x42, 0x00,
            UInt8(BIND_OPCODE_DO_BIND),
        ]

        // When
        when(opcodes: opcodes)

        // Then
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut[0].symbol, [0x41])
        XCTAssertEqual(sut[1].symbol, [0x42])
    }

    func test_dylibOrdinalShouldSurvive_DO_BIND() {
        // Given
        let opcodes = [
            UInt8(BIND_OPCODE_SET_DYLIB_ORDINAL_IMM) | 6,
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x41, 0x00,
            UInt8(BIND_OPCODE_DO_BIND),
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x42, 0x00,
            UInt8(BIND_OPCODE_DO_BIND),
        ]

        // When
        when(opcodes: opcodes)

        // Then
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut[0].dylibOrdinal, 6)
        XCTAssertEqual(sut[1].dylibOrdinal, 6)
    }

    func test_dylibOrdinalShouldNotSurvive_DONE() {
        // Given
        let opcodes = [
            UInt8(BIND_OPCODE_SET_DYLIB_ORDINAL_IMM) | 6,
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x41, 0x00,
            UInt8(BIND_OPCODE_DO_BIND),
            UInt8(BIND_OPCODE_DONE),
            UInt8(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM), 0x42, 0x00,
            UInt8(BIND_OPCODE_DO_BIND),
        ]

        // When
        when(opcodes: opcodes)

        // Then
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut[0].dylibOrdinal, 6)
        XCTAssertEqual(sut[1].dylibOrdinal, 0)
    }
}
