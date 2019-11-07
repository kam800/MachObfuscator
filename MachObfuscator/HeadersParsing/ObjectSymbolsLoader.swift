import Foundation

protocol ObjectSymbolsLoader {
    func load(from url: URL) throws -> ObjectSymbols
}
