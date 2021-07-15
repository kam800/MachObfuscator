import Foundation

extension URL {
    static var iosNib: URL {
        return Bundle.module.url(forResource: "IosView", withExtension: "nib")!
    }

    static var macNib: URL {
        return Bundle.module.url(forResource: "MacView", withExtension: "nib")!
    }
}
