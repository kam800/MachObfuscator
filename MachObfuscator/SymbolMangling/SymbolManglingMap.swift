import Foundation

struct SymbolManglingMap {
    typealias ObfuscationTriePair = (unobfuscated: Trie, obfuscated: Trie)

    typealias TriePerCpu = [CpuId: ObfuscationTriePair]

    var selectors: [String: String]

    var classNames: [String: String]

    var methTypes: [String: String]

    var exportTrieObfuscationMap: [URL: TriePerCpu]
}
