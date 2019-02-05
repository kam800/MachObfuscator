import Foundation

final class RealWordsMangler: SymbolMangling {
    var key: String = "realWords"

    let helpDescription: String = "replace objc symbols with random words and fill dyld info symbols with numbers"

    private let exportTrieMangler: RealWordsExportTrieMangling

    init(exportTrieMangler: RealWordsExportTrieMangling) {
        self.exportTrieMangler = exportTrieMangler
    }

    func mangleSymbols(_ symbols: ObfuscationSymbols) -> SymbolManglingMap {
        let sentenceGenerator = SentenceGenerator()
        let mangledSelectorsBlacklist = (Array(symbols.blacklist.selectors) + Array(symbols.whitelist.selectors)).uniq
        let mangledClassesBlacklist = (Array(symbols.blacklist.classes) + Array(symbols.whitelist.classes)).uniq
        let unmangledAndMangledSelectorPairs: [(String, String)] =
            symbols.whitelist
            .selectors
            .compactMap { selector in
                while let randomSelector = sentenceGenerator.getUniqueSentence(length: selector.count) {
                    if !mangledSelectorsBlacklist.contains(randomSelector) {
                        return (selector, randomSelector)
                    }
                }
                return nil
            }
        let unmangledAndMangledClassPairs: [(String, String)] =
            symbols.whitelist
            .classes
            .compactMap { className in
                while let randomClassName = sentenceGenerator.getUniqueSentence(length: className.count)?.capitalizedOnFirstLetter {
                    if !mangledClassesBlacklist.contains(randomClassName) {
                        return (className, randomClassName)
                    }
                }
                return nil
            }

        let identityManglingMap =
            symbols.exportTriesPerCpuIdPerURL
            .mapValues { exportTriesPerCpuId in
                return exportTriesPerCpuId.mapValues {
                    ($0, exportTrieMangler.mangle(trie: $0, fillingRootLabelWith: 0))
                }
            }

        return SymbolManglingMap(selectors: Dictionary(uniqueKeysWithValues: unmangledAndMangledSelectorPairs),
                                 classNames: Dictionary(uniqueKeysWithValues: unmangledAndMangledClassPairs),
                                 exportTrieObfuscationMap: identityManglingMap)
    }
}
