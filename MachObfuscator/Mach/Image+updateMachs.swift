import Foundation

extension Image {
    mutating func updateMachs(block: (inout Mach) -> Void) {
        switch contents {
        case let .fat(fat):
            var mutableFat = fat
            for var arch in mutableFat.architectures {
                block(&arch.mach)
                let archRangeInFat = Range(offset: Int(arch.offset), count: arch.mach.data.count)
                mutableFat.data.replaceSubrange(archRangeInFat, with: arch.mach.data)
            }
            contents = .fat(mutableFat)
        case let .mach(mach):
            var mutableMach = mach
            block(&mutableMach)
            contents = .mach(mutableMach)
        }
    }
}
