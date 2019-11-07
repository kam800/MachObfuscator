import Foundation

class ObjectSymbolsLoaderMock {
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

extension ObjectSymbolsLoaderMock: ObjectSymbolsLoader {
    func load(from url: URL) throws -> ObjectSymbols {
        let path = url.resolvingSymlinksInPath().path
        if let symbols = symbolsPerUrl[path] {
            return symbols
        } else {
            throw Error.noEntryForPath
        }
    }
}
