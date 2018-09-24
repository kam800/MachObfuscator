import Foundation

extension Data {
    func getStruct<T>(atOffset offset: Int) -> T {
        return withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            ptr.advanced(by: offset).getStruct()
        }
    }

    func getStructs<T>(atOffset offset: Int, count: Int) -> [T] {
        return withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            ptr.advanced(by: offset).getStructs(count: count)
        }
    }

    func getCString(atOffset offset: Int) -> String {
        return withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            String(cString: ptr.advanced(by: offset))
        }
    }
}
