import Foundation

struct ObfuscationSymbols {
    var whitelist: ObjCSymbols // those symbols should be obfuscated
    var blacklist: ObjCSymbols // mangling algorighms should avoid using blacklisted symbols
    var removedList: ObjCSymbols // symbols removed by blacklist
    var exportTriesPerCpuIdPerURL: [URL: [CpuId: Trie]] // export tries to be fully obfuscated
}

struct ObjCSymbols {
    var selectors: Set<String>
    var classes: Set<String>
}
