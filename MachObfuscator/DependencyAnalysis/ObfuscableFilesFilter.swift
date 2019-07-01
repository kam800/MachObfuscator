import Foundation

struct ObfuscableFilesFilter {
    let isObfuscable: (URL) -> Bool
}

extension ObfuscableFilesFilter {
    func and(_ other: ObfuscableFilesFilter) -> ObfuscableFilesFilter {
        return ObfuscableFilesFilter { url in
            self.isObfuscable(url) && other.isObfuscable(url)
        }
    }
    
    static func defaultObfuscableFilesFilter() -> ObfuscableFilesFilter {
        // > Swift apps no longer include dynamically linked libraries
        // > for the Swift standard library and Swift SDK overlays in
        // > build variants for devices running iOS 12.2, watchOS 5.2,
        // > and tvOS 12.2.
        // -- https://developer.apple.com/documentation/xcode_release_notes/xcode_10_2_beta_release_notes/swift_5_release_notes_for_xcode_10_2_beta
        return skipSwiftLibrary()
    }
    
    static func skipSwiftLibrary() -> ObfuscableFilesFilter {
        return ObfuscableFilesFilter { url in
            !url.lastPathComponent.starts(with: "libswift")
        }
    }
    
    static func onlyFiles(in obfuscableDirectory: URL) -> ObfuscableFilesFilter {
        return ObfuscableFilesFilter { url in
            obfuscableDirectory.contains(url)
        }
    }
    
    static func skipFramework(framework : String) -> ObfuscableFilesFilter {
        let frameworkComponent = framework + ".framework"
        return ObfuscableFilesFilter { url in
            !url.pathComponents.contains(frameworkComponent)
        }
    }
    
    static func skipAllFrameworks() -> ObfuscableFilesFilter {
        return ObfuscableFilesFilter { url in
            !url.pathComponents.contains("Frameworks")
        }
    }
    
}
