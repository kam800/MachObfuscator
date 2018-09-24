import Foundation

extension UnsafePointer {
    func getStruct<T>() -> T {
        return withMemoryRebound(to: T.self, capacity: 1, { ptr in
            ptr.pointee
        })
    }

    func getStructs<T>(count: Int) -> [T] {
        return withMemoryRebound(to: T.self, capacity: count, { ptr in
            [T](UnsafeBufferPointer(start: ptr, count: count))
        })
    }
}

extension UnsafePointer where Pointee == UInt8 {
    mutating func readStruct<T>() -> T {
        let result: T = getStruct()
        self = advanced(by: MemoryLayout<T>.stride)
        return result
    }

    mutating func readStructs<T>(count: Int) -> [T] {
        let result: [T] = getStructs(count: count)
        self = advanced(by: MemoryLayout<T>.stride * count)
        return result
    }
}
