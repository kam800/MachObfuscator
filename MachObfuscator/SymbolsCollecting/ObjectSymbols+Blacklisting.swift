import Foundation

extension ObjectSymbols {
    static func blacklist(skippedSymbolsSources: [URL],
                          skippedSymbolsLists: [URL],
                          sourceSymbolsLoader: ObjectSymbolsLoader,
                          symbolsListLoader: ObjectSymbolsLoader) -> ObjectSymbols {
        let skippedSourceSymbols = skippedSymbolsSources
            .map(sourceSymbolsLoader.forceLoad(from:))

        let skippedListSymbols = skippedSymbolsLists
            .map(symbolsListLoader.forceLoad(from:))

        return (skippedSourceSymbols + skippedListSymbols).flatten()
    }
}
