import Foundation

class ObfuscationSymbolsTestHeaderSymbolsLoader {
    fileprivate enum Error: Swift.Error {
        case noEntryForPath
    }

    private var symbolsPerUrl: [String: HeaderSymbols] = [:]

    subscript(path: String) -> HeaderSymbols? {
        get {
            return symbolsPerUrl[path]
        }
        set {
            symbolsPerUrl[path] = newValue
        }
    }

}

extension ObfuscationSymbolsTestHeaderSymbolsLoader: HeaderSymbolsLoader {
    func load(forFrameworkURL frameworkURL: URL) throws -> HeaderSymbols {
        let path = frameworkURL.resolvingSymlinksInPath().path
        if let symbols = symbolsPerUrl[path] {
            return symbols
        } else {
            throw Error.noEntryForPath
        }
    }
}
