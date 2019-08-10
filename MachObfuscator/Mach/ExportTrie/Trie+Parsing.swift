import Foundation

extension Trie {
    var exportedLabelStrings: [String] {
        return exportedLabels.compactMap { String(bytes: $0, encoding: .utf8) }
    }

    private var exportedLabels: [[UInt8]] {
        let childrenLabels = children.flatMap { $0.exportedLabels }.map { label + $0 }
        if exportsSymbol {
            return [label] + childrenLabels
        } else {
            return childrenLabels
        }
    }

    var flatNodes: [Trie] {
        var result = [self]
        var queue = [self]
        while let nextNode = queue.popLast() {
            let children = nextNode.children
            result += children
            queue += children
        }
        return result
    }
}
