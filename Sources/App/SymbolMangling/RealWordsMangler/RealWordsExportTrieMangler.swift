import Foundation

protocol RealWordsExportTrieMangling: AnyObject {
    func mangle(trie: Trie) -> Trie
}

final class RealWordsExportTrieMangler: RealWordsExportTrieMangling {
    private let minimumFillValue: UInt8

    init(machOViewDoomEnabled: Bool) {
        minimumFillValue = machOViewDoomEnabled ? 0 : 1
    }

    func mangle(trie: Trie) -> Trie {
        // In case of Mach-O trie binary-representation, a root trie node doesn't even have a space to store its label.
        // That's why it is always empty in the `Trie` struct. But it feels unsafe to pass `0` for
        // `fillingRootLabelWith`, because `0` is a cstring end marker.
        var mutableTrie = trie
        _ = mutableTrie.fillRecursively(startingWithFillValue: minimumFillValue,
                                        minimumFillValue: minimumFillValue)
        return mutableTrie
    }
}

private extension Trie {
    struct FillResult {
        var finalFillValue: UInt8
    }

    mutating func fillRecursively(startingWithFillValue initialFillValue: UInt8,
                                  minimumFillValue: UInt8) -> FillResult {
        label = Array(repeating: initialFillValue, count: label.count)
        var childFillValue = label.isEmpty
            ? initialFillValue // children won't get any prefix from their parent, need to iterate the parent's fillValue
            : minimumFillValue // children are safe to be filled with independent enumeration
        for childIdx in children.indices {
            let fillResult = children[childIdx].fillRecursively(startingWithFillValue: childFillValue,
                                                                minimumFillValue: minimumFillValue)
            childFillValue = fillResult.finalFillValue // child decides about syncing the iterator back
        }

        if label.isEmpty {
            // need to sync parent fillValue iterator back
            return FillResult(finalFillValue: childFillValue)
        } else {
            // children use independent iteration, just increment parent's fillValue iterator
            let addResult = initialFillValue.addingReportingOverflow(1)
            guard !addResult.overflow else {
                fatalError("Trie label values probably exhausted at \(labelRange)")
            }
            return FillResult(finalFillValue: addResult.partialValue)
        }
    }
}
