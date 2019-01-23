import Foundation

protocol RealWordsExportTrieMangling: AnyObject {
    func mangle(trie: Trie, fillingRootLabelWith labelFill: UInt8) -> Trie
}

final class RealWordsExportTrieMangler: RealWordsExportTrieMangling {
    func mangle(trie: Trie, fillingRootLabelWith labelFill: UInt8) -> Trie {
        var trieCopy = trie

        trieCopy.label = trieCopy.label.map { _ in
            labelFill
        }

        trieCopy.children = trieCopy.children.enumerated().map { (index, child) -> Trie in
            guard let labelFill = UInt8(exactly: index + 1) else {
                fatalError("Trie label values probably exhausted at \(child.labelRange)")
            }

            return mangle(trie: child, fillingRootLabelWith: labelFill)
        }

        return trieCopy
    }
}
