import Foundation

protocol RealWordsExportTrieMangling: AnyObject {
    func mangle(trie: Trie, fillingRootLabelWith labelFill: UInt8) -> Trie
}

final class RealWordsExportTrieMangler: RealWordsExportTrieMangling {
    private let machOViewDoomEnabled: Bool

    init(machOViewDoomEnabled: Bool) {
        self.machOViewDoomEnabled = machOViewDoomEnabled
    }

    func mangle(trie: Trie, fillingRootLabelWith labelFill: UInt8) -> Trie {
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
