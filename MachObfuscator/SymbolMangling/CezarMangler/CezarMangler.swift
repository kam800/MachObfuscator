import Foundation

class CezarMangler: SymbolMangling {
    static let key: String = "cezar"
    static let helpDescription: String = "ROT13 all objc symbols and dyld info"

    required init() {}

    func mangleSymbols(_ symbols: ObfuscationSymbols) -> SymbolManglingMap {
        let mangledClasses = symbols.whitelist.classes.map { ($0, String($0.obfuscated)) }
        let classesMap = Dictionary(uniqueKeysWithValues: mangledClasses)
        let mangledSelectors = symbols.whitelist.selectors.map { ($0, String($0.obfuscated)) }
        let selectorsMap = Dictionary(uniqueKeysWithValues: mangledSelectors)

        if let clashedSymbol = classesMap.values.first(where: { symbols.blacklist.classes.contains($0) })
            ?? selectorsMap.values.first(where: { symbols.blacklist.selectors.contains($0) }) {
            fatalError("ReverseMangler clashed on symbol '\(clashedSymbol)'")
        }

        let unobfuscatedObfuscatedTriePairPerCpuIdPerURL: [URL: [CpuId: (Trie, Trie)]] = symbols.exportTriesPerCpuIdPerURL.mapValues { $0.mapValues { ($0, $0.obfucated) } }

        return SymbolManglingMap(selectors: selectorsMap,
                                 classNames: classesMap,
                                 unobfuscatedObfuscatedTriePairPerCpuIdPerURL: unobfuscatedObfuscatedTriePairPerCpuIdPerURL)
    }
}

private extension Trie {
    var obfucated: Trie {
        var trie = self
        trie.obfuscate()
        return trie
    }

    mutating func obfuscate() {
        label = label.map { $0.obfuscated }
        children = children.map { $0.obfucated }
    }
}

private extension StringProtocol {
    var obfuscated: String {
        if hasPrefix("set") {
            return "set" + (self[index(startIndex, offsetBy: 3)...]).obfuscated
        }
        return String(bytes: utf8.map { $0.obfuscated }, encoding: .utf8)!
    }
}

private extension UInt8 {
    private static let asciiRange = UInt8(33) ... UInt8(126)
    private static let cipherKey: UInt8 = 13

    var obfuscated: UInt8 {
        if self == 0x3A /* ":" */ {
            return self
        } else if UInt8.asciiRange.contains(self) {
            if UInt8.asciiRange.contains(self + UInt8.cipherKey) {
                return self + UInt8.cipherKey
            } else {
                return self + UInt8.cipherKey - UInt8(UInt8.asciiRange.count)
            }
        } else {
            return self
        }
    }
}
