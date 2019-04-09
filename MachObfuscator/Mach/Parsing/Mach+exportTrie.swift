import Foundation

extension Mach {
    var exportedTrie: Trie? {
        guard let dyldInfo = dyldInfo else {
            return nil
        }
        return Trie(data: data, rootNodeOffset: Int(dyldInfo.exportRange.lowerBound))
    }
}
