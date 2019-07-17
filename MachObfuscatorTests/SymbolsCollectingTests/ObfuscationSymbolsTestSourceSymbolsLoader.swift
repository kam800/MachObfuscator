import Foundation

class ObfuscationSymbolsTestSourceSymbolsLoader {
    fileprivate enum Error: Swift.Error {
        case noEntryForPath
    }

    private var symbolsPerUrl: [String: SourceSymbols] = [:]

    subscript(path: String) -> SourceSymbols? {
        get {
            return symbolsPerUrl[path]
        }
        set {
            symbolsPerUrl[path] = newValue
        }
    }

}

extension ObfuscationSymbolsTestSourceSymbolsLoader: SourceSymbolsLoader {
    func load(forFrameworkURL frameworkURL: URL) throws -> SourceSymbols {
        let path = frameworkURL.resolvingSymlinksInPath().path
        if let symbols = symbolsPerUrl[path] {
            return symbols
        } else {
            throw Error.noEntryForPath
        }
    }
}
