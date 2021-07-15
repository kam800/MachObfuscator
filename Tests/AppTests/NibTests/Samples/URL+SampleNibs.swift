import Foundation

extension URL {
    private class MarkerClass {}

    static var iosNib: URL {
        return Bundle(for: MarkerClass.self).url(forResource: "IosView", withExtension: "nib")!
    }

    static var macNib: URL {
        return Bundle(for: MarkerClass.self).url(forResource: "MacView", withExtension: "nib")!
    }
}
