import Foundation

extension Image {
    var machs: [Mach] {
        switch contents {
        case let .fat(fat):
            return fat.architectures.map { $0.mach }
        case let .mach(mach):
            return [mach]
        }
    }
}
