import Foundation

struct SymbolManglingMap {
    typealias ObfuscationTriePair = (unobfuscated: Trie, obfuscated: Trie)

    typealias TriesPerCpu = [CpuId: ObfuscationTriePair]

    var selectors: [String: String]

    var classNames: [String: String]

    var exportTrieObfuscationMap: [URL: TriesPerCpu]
}
