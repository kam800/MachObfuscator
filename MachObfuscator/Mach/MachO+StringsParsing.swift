import Foundation
import MachO

extension segment_command_64 {
    var name: String {
        return String(bytesTuple: segname)
    }
}

extension segment_command {
    var name: String {
        return String(bytesTuple: segname)
    }
}

extension section_64 {
    var name: String {
        return String(bytesTuple: sectname)
    }
}

extension section {
    var name: String {
        return String(bytesTuple: sectname)
    }
}

extension String {
    init(bytesTuple: (Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8)) {
        var table = [Int8](repeating: 0, count: 17)
        withUnsafePointer(to: bytesTuple) { ptr in
            ptr.withMemoryRebound(to: Int8.self, capacity: 16) { ptr in
                for i in 0 ..< 16 {
                    table[i] = ptr[i]
                }
            }
        }
        self.init(cString: table)
    }
}
