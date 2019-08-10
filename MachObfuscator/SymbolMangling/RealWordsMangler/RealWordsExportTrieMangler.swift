import Foundation

protocol RealWordsExportTrieMangling: AnyObject {
    func mangle(trie: Trie) -> Trie
}

final class RealWordsExportTrieMangler: RealWordsExportTrieMangling {
    private let machOViewDoomEnabled: Bool

    init(machOViewDoomEnabled: Bool) {
        self.machOViewDoomEnabled = machOViewDoomEnabled
    }

    func mangle(trie: Trie) -> Trie {
        // In case of Mach-O trie binary-representation, a root trie node doesn't even have a space to store its label.
        // That's why it is always empty in the `Trie` struct. But it feels unsafe to pass `0` for
        // `fillingRootLabelWith`, because `0` is a cstring end marker.
        return mangle(trie: trie, fillingRootLabelWith: 1)
    }

    private func mangle(trie: Trie, fillingRootLabelWith labelFill: UInt8) -> Trie {
        var trieCopy = trie

        trieCopy.label = trieCopy.label.map { _ in
            labelFill
        }

        trieCopy.children = trieCopy.children.enumerated().map { (index, child) -> Trie in
            let addingComponent = machOViewDoomEnabled ? 0 : 1
            guard let labelFill = UInt8(exactly: index + addingComponent) else {
                fatalError("Trie label values probably exhausted at \(child.labelRange)")
            }

            return mangle(trie: child, fillingRootLabelWith: labelFill)
        }

        return trieCopy
    }
}
