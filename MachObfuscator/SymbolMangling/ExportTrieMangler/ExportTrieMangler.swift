import Foundation

protocol ExportTrieMangling: AnyObject {
    func mangle(trie: Trie, with label: UInt8) -> Trie
}

final class ExportTrieMangler: ExportTrieMangling {
    func mangle(trie: Trie, with value: UInt8 = 0) -> Trie {
        var trieCopy = trie

        trieCopy.label = trieCopy.label.map { _ in
            value
        }

        trieCopy.children = trieCopy.children.enumerated().map { (index, child) -> Trie in
            mangle(trie: child, with: UInt8(index + 1))
        }

        return trieCopy
    }
}
