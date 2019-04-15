import Foundation

class RpathsAccumulator {
    private let executablePath: URL
    private var searchPathsPerPlatform: [Mach.Platform: [URL] = [:]

    init(executablePath: URL) {
        self.executablePath = executablePath
    }

    func add(rpaths: [String], loaderPath: URL, platform: Mach.Platform) {
        rpaths.forEach { rpath in
            add(rpath: rpath, loaderPath: loaderPath, platform: platform)
        }
    }

    private func add(rpath: String, loaderPath: URL, platform: Mach.Platform) {
        let firstPathSeparator = rpath.index(of: Paths.separator) ?? rpath.endIndex
        let firstPathComponentRange = rpath.startIndex ..< firstPathSeparator
        let resolvedRpath: String
        switch rpath[firstPathComponentRange] {
        case "@executable_path":
            resolvedRpath = rpath.replacingCharacters(in: firstPathComponentRange, with: executablePath.path)
        case "@loader_path":
            resolvedRpath = rpath.replacingCharacters(in: firstPathComponentRange, with: loaderPath.path)
        default:
            resolvedRpath = platform.translated(path: rpath)
        }
        let searchPath: URL = URL(fileURLWithPath: resolvedRpath).resolvingSymlinksInPath()
        searchPathsPerPlatform[platform, default: [executablePath]].appendUnique(searchPath)
    }

    func resolve(dylibEntry: String,
                 loaderPath: URL,
                 platform: Mach.Platform,
                 fileRepository: FileRepository) -> URL? {
        let firstPathSeparator = dylibEntry.index(of: Paths.separator) ?? dylibEntry.endIndex
        let firstPathComponentRange = dylibEntry.startIndex ..< firstPathSeparator
        let possibleDylibs: [String]
        switch dylibEntry[firstPathComponentRange] {
        case "@executable_path":
            possibleDylibs = [dylibEntry.replacingCharacters(in: firstPathComponentRange,
                                                             with: executablePath.path)]
        case "@loader_path":
            possibleDylibs = [dylibEntry.replacingCharacters(in: firstPathComponentRange,
                                                             with: loaderPath.path)]
        case "@rpath":
            possibleDylibs = searchPathsPerPlatform[platform, default: [executablePath]]
                .map { searchPath in
                    dylibEntry.replacingCharacters(in: firstPathComponentRange,
                                                   with: searchPath.path)
                }
        default:
            possibleDylibs = [platform.translated(path: dylibEntry)]
        }

        guard let resolvedDylib = possibleDylibs.map(URL.init(fileURLWithPath:))
            .first(where: { fileRepository.fileExists(atURL: $0) }) else {
            // TODO: read all fatalError and replace ! with fatalError
            return nil
        }

        return resolvedDylib
    }
}

private extension Mach.Platform {
    func translated(path: String) -> String {
        if self == .ios, path.starts(with: "/") {
            // prefix ios root paths with ios runtime path
            return Paths.iosRuntimeRoot.appending(path)
        } else {
            return path
        }
    }
}

extension Array where Element: Equatable {
    mutating func appendUnique(_ element: Element) {
        guard !contains(element) else {
            return
        }
        append(element)
    }
}
