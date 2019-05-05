import Foundation

protocol HeaderSymbolsLoader {
    func load(forFrameworkURL frameworkURL: URL) throws -> HeaderSymbols
}
