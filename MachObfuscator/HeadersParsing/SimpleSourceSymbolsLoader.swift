import Foundation

class SimpleSourceSymbolsLoader: SourceSymbolsLoader {
    func load(forFrameworkURL frameworkURL: URL) throws -> ObjectSymbols {
        return try load(forFrameworkURL: frameworkURL, fileManager: FileManager.default)
    }

    func load(forFrameworkURL frameworkURL: URL, fileManager: FileManager) throws -> ObjectSymbols {
        let headers = fileManager.listSourceFilesRecursively(atURL: frameworkURL)
        return headers.map(ObjectSymbols.load(url:)).flatten()
    }
}

private extension FileManager {
    func listSourceFilesRecursively(atURL url: URL) -> [URL] {
        return listFilesRecursively(atURL: url)
            .filter { $0.isSourceFile }
    }
}

private extension URL {
    private static let sourceFileExtensionSet: Set<String> = ["h", "m"]
    var isSourceFile: Bool {
        return URL.sourceFileExtensionSet.contains(pathExtension)
    }
}

private extension ObjectSymbols {
    static func load(url: URL) -> ObjectSymbols {
        let sourceContents: String
        do {
            sourceContents = try String(contentsOf: url, encoding: .ascii)
        } catch {
            fatalError("Could not read \(url) because: \(error.localizedDescription)")
        }
        let selectors = Set(sourceContents.objCMethodNames)
            .union(sourceContents.objCPropertyNames)
        let classNames = Set(sourceContents.objCTypeNames)
        return ObjectSymbols(selectors: selectors, classNames: classNames)
    }
}

extension Sequence where Element == ObjectSymbols {
    func flatten() -> ObjectSymbols {
        return reduce(into: ObjectSymbols(selectors: [], classNames: [])) { result, nextSymbols in
            result.classNames.formUnion(nextSymbols.classNames)
            result.selectors.formUnion(nextSymbols.selectors)
        }
    }
}
