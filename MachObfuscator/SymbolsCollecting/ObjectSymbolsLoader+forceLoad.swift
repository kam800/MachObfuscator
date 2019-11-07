import Foundation

extension ObjectSymbolsLoader {
    func forceLoad(from url: URL) -> ObjectSymbols {
        do {
            LOGGER.info("Collecting symbols from \(url)")
            return try load(from: url)
        } catch {
            fatalError("Error while reading symbols from path '\(url)': \(error)")
        }
    }
}
