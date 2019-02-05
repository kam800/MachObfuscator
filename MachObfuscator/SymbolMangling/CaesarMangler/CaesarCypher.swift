import Foundation

final class CaesarCypher {
    private let asciiRange = UInt8(33) ... UInt8(126)

    func encrypt(element: UInt8, key: UInt8) -> UInt8 {
        if representsAsciiSemicolon(element) {
            return element
        }

        if asciiRange.contains(element) {
            let elementShiftedByKey: UInt8 = element + key
            return asciiRange.contains(elementShiftedByKey) ? elementShiftedByKey
                : elementShiftedByKey - UInt8(asciiRange.count)
        }

        return element
    }

    private func representsAsciiSemicolon(_ value: UInt8) -> Bool {
        return value == 0x3A
    }
}
