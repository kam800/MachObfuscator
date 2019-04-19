import Foundation

extension UnsafeRawPointer {
    mutating func readStringBytes() -> [UInt8] {
        let basePtr = self
        while load(as: UInt8.self) != 0 {
            self = advanced(by: 1)
        }
        defer {
            self = advanced(by: 1) // skip terminal 0
        }
        return [UInt8](UnsafeRawBufferPointer(start: basePtr, count: basePtr.distance(to: self)))
    }
}
