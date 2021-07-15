@testable import App
import Foundation

class RecursiveSourceSymbolsLoaderMock {
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

extension RecursiveSourceSymbolsLoaderMock: RecursiveSourceSymbolsLoaderProtocol {
    func load(fromDirectory url: URL) -> ObjectSymbols {
        let path = url.resolvingSymlinksInPath().path
        if let symbols = symbolsPerUrl[path] {
            return symbols
        } else {
            return ObjectSymbols(selectors: [], classNames: [])
        }
    }
}
