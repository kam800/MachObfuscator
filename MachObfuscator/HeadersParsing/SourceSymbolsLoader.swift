import Foundation

protocol SourceSymbolsLoader {
    func load(forFrameworkURL frameworkURL: URL) throws -> ObjectSymbols
}
