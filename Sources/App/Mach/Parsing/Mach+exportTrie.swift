import Foundation

extension Mach {
    var exportedTrie: Trie? {
        guard let dyldInfo = dyldInfo,
            !dyldInfo.exportRange.isEmpty
        else { return nil }
        return Trie(data: data, rootNodeOffset: Int(dyldInfo.exportRange.lowerBound))
    }
}
