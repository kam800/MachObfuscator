import Foundation

extension Data {
    var magic: UInt32? {
        guard count >= MemoryLayout<UInt32>.size else {
            return nil
        }
        return withUnsafeBytes { (ptr: UnsafePointer<UInt32>) in
            ptr.pointee
        }
    }
}
