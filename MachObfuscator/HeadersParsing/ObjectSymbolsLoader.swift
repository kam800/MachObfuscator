import Foundation

protocol ObjectSymbolsLoader {
    func load(forFrameworkURL frameworkURL: URL) throws -> ObjectSymbols
}
