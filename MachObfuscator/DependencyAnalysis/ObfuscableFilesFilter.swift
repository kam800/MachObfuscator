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

    func negate() -> ObfuscableFilesFilter {
        return ObfuscableFilesFilter { !self.isObfuscable($0) }
    }

    func whitelist(_ other: ObfuscableFilesFilter) -> ObfuscableFilesFilter {
        return ObfuscableFilesFilter { url in
            // Order of checks is important.
            // Adding whitelisted frameworks at the beginning and blacklisted at the end
            // makes the system behave as might be expected,
            // because it creates following expression:
            // isObfuscable = whitelist3 || whitelist2 || whitelist1 || ( !blacklist1 && !blacklist2 )
            other.isObfuscable(url) || self.isObfuscable(url)
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

    static func isFramework(framework: String) -> ObfuscableFilesFilter {
        let frameworkComponent = framework + ".framework"
        return ObfuscableFilesFilter { url in
            url.pathComponents.contains(frameworkComponent)
        }
    }

    static func skipFramework(framework: String) -> ObfuscableFilesFilter {
        return isFramework(framework: framework).negate()
    }

    static func skipAllFrameworks() -> ObfuscableFilesFilter {
        return ObfuscableFilesFilter { url in
            !url.pathComponents.contains("Frameworks")
        }
    }
}
