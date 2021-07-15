import Foundation

extension Image {
    func save() {
        switch contents {
        case let .fat(fat):
            try! fat.data.write(to: url)
        case let .mach(mach):
            try! mach.data.write(to: url)
        }
    }
}
