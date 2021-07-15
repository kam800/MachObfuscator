import Foundation

extension URL {
    private class MarkerClass {}

    static var craftedFramework: URL {
        return Bundle(for: MarkerClass.self).url(forResource: "CraftedFramework", withExtension: "framework")!
    }

    static var systemLikeFramework: URL {
        return Bundle(for: MarkerClass.self).url(forResource: "SystemLikeFramework", withExtension: "framework")!
    }

    static var librarySourceCode: URL {
        return Bundle(for: MarkerClass.self).url(forResource: "LibrarySourceCode", withExtension: "bundle")!
    }
}
