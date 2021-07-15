import Foundation

extension Data {
    var magic: UInt32? {
        guard count >= MemoryLayout<UInt32>.size else {
            return nil
        }
        return withUnsafeBytes { $0.load(as: UInt32.self) }
    }
}
