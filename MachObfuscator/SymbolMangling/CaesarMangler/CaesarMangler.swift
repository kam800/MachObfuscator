import Foundation

final class CaesarMangler: SymbolMangling {
    private let exportTrieMangler: CaesarExportTrieMangling

    private let caesarStringMangler: CaesarStringMangling = CaesarStringMangler()

    private let cypherKey: UInt8 = 13

    init(exportTrieMangler: CaesarExportTrieMangling) {
        self.exportTrieMangler = exportTrieMangler
    }

    func mangleSymbols(_ symbols: ObfuscationSymbols) -> SymbolManglingMap {
        let mangledClasses = symbols.whitelist.classes.map {
            ($0, caesarStringMangler.mangle($0, usingCypherKey: cypherKey))
        }

        let selectorsManglingEntryProvider: [(String, String)] = symbols.whitelist.selectors.map {
            ($0, caesarStringMangler.mangle($0, usingCypherKey: cypherKey))
        }

        let mangledSelectors = selectorsManglingEntryProvider

        let classesMap = Dictionary(uniqueKeysWithValues: mangledClasses)
        let selectorsMap = Dictionary(uniqueKeysWithValues: mangledSelectors)

        if let clashedSymbol = classesMap.values.first(where: { symbols.blacklist.classes.contains($0) })
            ?? selectorsMap.values.first(where: { symbols.blacklist.selectors.contains($0) }) {
            fatalError("ReverseMangler clashed on symbol '\(clashedSymbol)'")
        }

        let triesPerCpuAtUrl: [URL: SymbolManglingMap.TriePerCpu] = symbols.exportTriesPerCpuIdPerURL.mapValues {
            $0.mapValues {
                SymbolManglingMap.ObfuscationTriePair(unobfuscated: $0,
                                                      obfuscated: exportTrieMangler.mangle(trie: $0, withCaesarCypherKey: cypherKey))
            }
        }

        return SymbolManglingMap(selectors: selectorsMap, classNames: classesMap, exportTrieObfuscationMap: triesPerCpuAtUrl)
    }
}
