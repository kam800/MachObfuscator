import Foundation

extension UnsafeRawPointer {
    func getStruct<T>() -> T {
        return bindMemory(to: T.self, capacity: 1)
            .pointee
    }

    func getStructs<T>(count: Int) -> [T] {
        return bindMemory(to: T.self, capacity: count)
            |> { UnsafeBufferPointer<T>(start: $0, count: count) }
            |> [T].init
    }
}

extension UnsafeRawPointer {
    mutating func readStruct<T>() -> T {
        defer {
            // TODO: size?
            self = advanced(by: MemoryLayout<T>.stride)
        }
        return getStruct()
    }

    mutating func readStructs<T>(count: Int) -> [T] {
        defer {
            self = advanced(by: MemoryLayout<T>.stride * count)
        }
        return getStructs(count: count)
    }
}
