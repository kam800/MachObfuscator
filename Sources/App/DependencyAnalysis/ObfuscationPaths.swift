import Foundation

struct ObfuscationPaths {
    var obfuscableImages: Set<URL> = []
    var unobfuscableDependencies: Set<URL> = []
    var systemFrameworks: Set<URL> = []
    var resolvedDylibMapPerImageURL: [URL: [String: URL]] = [:]
    var nibs: Set<URL> = []
}
