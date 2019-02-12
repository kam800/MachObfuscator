import Foundation

final class CaesarMangler: SymbolMangling {
    private let exportTrieMangler: CaesarExportTrieMangling

    private let caesarStringMangler: CaesarStringMangling = CaesarStringMangler()

    init(exportTrieMangler: CaesarExportTrieMangling) {
        self.exportTrieMangler = exportTrieMangler
    }

    func mangleSymbols(_ symbols: ObfuscationSymbols) -> SymbolManglingMap {
        let mangledClasses = symbols.whitelist.classes.map {
            ($0, caesarStringMangler.mangle($0, usingCypherKey: 13))
        }

        let mangledSelectors = symbols.whitelist.selectors.map {
            ($0, caesarStringMangler.mangle($0, usingCypherKey: 13))
        }

        let classesMap = Dictionary(uniqueKeysWithValues: mangledClasses)
        let selectorsMap = Dictionary(uniqueKeysWithValues: mangledSelectors)
        let methTypesMap = [String: String]()

        if let clashedSymbol = classesMap.values.first(where: { symbols.blacklist.classes.contains($0) })
            ?? selectorsMap.values.first(where: { symbols.blacklist.selectors.contains($0) }) {
            fatalError("ReverseMangler clashed on symbol '\(clashedSymbol)'")
        }

        let triesPerCpuAtUrl: [URL: SymbolManglingMap.TriePerCpu] = symbols.exportTriesPerCpuIdPerURL.mapValues {
            $0.mapValues {
                SymbolManglingMap.ObfuscationTriePair(unobfuscated: $0,
                                                      obfuscated: exportTrieMangler.mangle(trie: $0, withCaesarCypherKey: 13))
            }
        }

        return SymbolManglingMap(selectors: selectorsMap, classNames: classesMap, methTypes: methTypesMap, exportTrieObfuscationMap: triesPerCpuAtUrl)
    }
}
