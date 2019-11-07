import Foundation

extension ObjectSymbols {
    static func blacklist(skippedSymbolsSources: [URL],
                          sourceSymbolsLoader: SourceSymbolsLoader) -> ObjectSymbols {
        let skippedSymbols = skippedSymbolsSources
            .map(sourceSymbolsLoader.forceLoad(forFrameworkURL:))
            .flatten()

        return skippedSymbols
    }
}

// TODO: private in next PR
extension SourceSymbolsLoader {
    func forceLoad(forFrameworkURL url: URL) -> ObjectSymbols {
        do {
            LOGGER.info("Collecting symbols from \(url)")
            return try load(forFrameworkURL: url)
        } catch {
            fatalError("Error while reading symbols from path '\(url)': \(error)")
        }
    }
}
