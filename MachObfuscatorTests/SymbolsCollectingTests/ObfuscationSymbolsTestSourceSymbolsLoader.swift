import Foundation

class ObfuscationSymbolsTestSourceSymbolsLoader {
    private enum Error: Swift.Error {
        case noEntryForPath
    }

    private var symbolsPerUrl: [String: ObjectSymbols] = [:]

    subscript(path: String) -> ObjectSymbols? {
        get {
            return symbolsPerUrl[path]
        }
        set {
            symbolsPerUrl[path] = newValue
        }
    }
}

extension ObfuscationSymbolsTestSourceSymbolsLoader: SourceSymbolsLoader {
    func load(forFrameworkURL frameworkURL: URL) throws -> ObjectSymbols {
        let path = frameworkURL.resolvingSymlinksInPath().path
        if let symbols = symbolsPerUrl[path] {
            return symbols
        } else {
            throw Error.noEntryForPath
        }
    }
}
