import Foundation

extension ObjectSymbols {
    static func blacklist(skippedSymbolsSources: [URL],
                          sourceSymbolsLoader: ObjectSymbolsLoader) -> ObjectSymbols {
        skippedSymbolsSources
            .map(sourceSymbolsLoader.forceLoad(from:))
            .flatten()
    }

    static func blacklist(skippedSymbolsLists: [URL],
                          symbolsListLoader: ObjectSymbolsLoader) -> ObjectSymbols {
        skippedSymbolsLists
            .map(symbolsListLoader.forceLoad(from:))
            .flatten()
    }
}
