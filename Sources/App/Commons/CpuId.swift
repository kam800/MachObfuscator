import Foundation

typealias CpuId = Int64

extension Mach.Cpu {
    var asCpuId: CpuId {
        return (Int64(UInt32(bitPattern: type)) << 32) | Int64(UInt32(bitPattern: subtype))
    }
}
