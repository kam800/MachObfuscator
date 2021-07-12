import Foundation

class TextFileSymbolListLoaderMock {
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

extension TextFileSymbolListLoaderMock : TextFileSymbolListLoaderProtocol {
    func load(fromTextFile url: URL) -> ObjectSymbols {
        let path = url.resolvingSymlinksInPath().path
        if let symbols = symbolsPerUrl[path] {
            return symbols
        } else {
            return ObjectSymbols(selectors: [], classNames: [])
        }
    }
}
