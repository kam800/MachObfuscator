import Foundation

extension Mach: SymbolsSource {}
extension SimpleImageLoader: SymbolsSourceLoader {
    func load(forURL url: URL) throws -> [SymbolsSource] {
        return (try load(forURL: url)).machs
    }
}
