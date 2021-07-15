import Foundation

extension URL {
    static var craftedFramework: URL {
        return Bundle.module.url(forResource: "CraftedFramework", withExtension: "framework")!
    }

    static var systemLikeFramework: URL {
        return Bundle.module.url(forResource: "SystemLikeFramework", withExtension: "framework")!
    }

    static var librarySourceCode: URL {
        return Bundle.module.url(forResource: "LibrarySourceCode", withExtension: "bundle")!
    }
}
