import Foundation

extension FileRepository {
    func resolvedSystemFrameworkLocations(dylibEntry: String, referencingURL: URL, dependencyNodeLoader: DependencyNodeLoader) -> [URL] {
        guard dylibEntry.isSystemFrameworkEntry else {
            return []
        }
        let dylibEntryComponents = dylibEntry.components(separatedBy: "/")
        guard let frameworkComponentIndex = dylibEntryComponents.firstIndex(where: { $0.hasSuffix(".framework") }) else {
            return []
        }
        let frameworkPath = dylibEntryComponents[0 ... frameworkComponentIndex].joined(separator: "/")
        return dependencyNodeLoader.platforms(forURL: referencingURL)
            .map { $0.translated(path: frameworkPath) }
            .map(URL.init(fileURLWithPath:))
            .filter(fileExists(atURL:))
    }
}

private extension String {
    var isSystemFrameworkEntry: Bool {
        return hasPrefix("/") && contains(".framework")
    }
}

private extension DependencyNodeLoader {
    func platforms(forURL url: URL) -> [Mach.Platform] {
        let nodes: [DependencyNode]
        do {
            nodes = try load(forURL: url)
        } catch {
            fatalError("Failed loading \(url) because: \(error)")
        }
        return nodes.map { $0.platform }
    }
}

private extension Mach.Platform {
    func translated(path: String) -> String {
        switch self {
        case .ios:
            return Paths.iosFrameworksRoot.appending(path)
        case .macos:
            return Paths.macosFrameworksRoot.appending(path)
        }
    }
}
