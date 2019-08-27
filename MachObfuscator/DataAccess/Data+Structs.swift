import Foundation

extension Data {
    func getStruct<T>(atOffset offset: Int) -> T {
        return withUnsafeBytes {
            $0.baseAddress!
                .advanced(by: offset)
                .getStruct()
        }
    }

    func getStructs<T>(atOffset offset: Int, count: Int) -> [T] {
        return withUnsafeBytes {
            $0.baseAddress!
                .advanced(by: offset)
                .getStructs(count: count)
        }
    }

    func getStructs<T>(fromRange range: Range<Int>) -> [T] {
        return getStructs(atOffset: range.startIndex, count: range.count / MemoryLayout<T>.stride)
    }

    func getCString(atOffset offset: Int) -> String {
        return withUnsafeBytes {
            $0.bindMemory(to: UInt8.self)
                .baseAddress!
                .advanced(by: offset)
                |> String.init(cString:)
        }
    }
}
