import Foundation

protocol SymbolsSourceLoader {
    func load(forURL url: URL) throws -> [SymbolsSource]
}
