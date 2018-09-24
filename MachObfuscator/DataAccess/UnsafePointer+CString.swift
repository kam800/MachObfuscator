import Foundation

extension UnsafePointer where Pointee == UInt8 {
    mutating func readStringBytes() -> [UInt8] {
        let basePtr = self
        while pointee != 0 {
            self = advanced(by: 1)
        }
        let cString = Array(UnsafeBufferPointer(start: basePtr, count: basePtr.distance(to: self)))
        self = advanced(by: 1) // skip terminal 0
        return cString
    }
}
