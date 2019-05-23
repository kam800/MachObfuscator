import Foundation

class SimpleHeaderSymbolsLoader: HeaderSymbolsLoader {
    func load(forFrameworkURL frameworkURL: URL) throws -> HeaderSymbols {
        return try load(forFrameworkURL: frameworkURL, fileManager: FileManager.default)
    }

    func load(forFrameworkURL frameworkURL: URL, fileManager: FileManager) throws -> HeaderSymbols {
        let headers = fileManager.listHeaderFilesRecursively(atURL: frameworkURL)
        return headers.map(HeaderSymbols.load(url:)).flatten()
    }
}

private extension FileManager {
    func listHeaderFilesRecursively(atURL url: URL) -> [URL] {
        return listFilesRecursively(atURL: url)
            .filter { $0.isHeaderFile }
    }
}

private extension URL {
    var isHeaderFile: Bool {
        return pathExtension == "h"
    }
}

private extension HeaderSymbols {
    static func load(url: URL) -> HeaderSymbols {
        let headerContents: String
        do {
            headerContents = try String(contentsOf: url, encoding: .ascii)
        } catch {
            fatalError("Could not read \(url) because: \(error.localizedDescription)")
        }
        let selectors = Set(headerContents.objCMethodNames)
            .union(headerContents.objCPropertyNames)
        let classNames = Set(headerContents.objCTypeNames)
        return HeaderSymbols(selectors: selectors, classNames: classNames)
    }
}

extension Sequence where Element == HeaderSymbols {
    func flatten() -> HeaderSymbols {
        return reduce(into: HeaderSymbols(selectors: [], classNames: [])) { result, nextSymbols in
            result.classNames.formUnion(nextSymbols.classNames)
            result.selectors.formUnion(nextSymbols.selectors)
        }
    }
}
