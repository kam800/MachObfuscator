import Foundation

struct SymbolManglingMap {
    var selectors: [String: String]
    var classNames: [String: String]
    var unobfuscatedObfuscatedTriePairPerCpuIdPerURL: [URL: [CpuId: (Trie, Trie)]]
}
