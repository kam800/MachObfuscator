import Foundation

protocol CaesarExportTrieMangling: AnyObject {
    func mangle(trie: Trie, withCaesarCypherKey cypherKey: UInt8) -> Trie
}

final class CaesarExportTrieMangler: CaesarExportTrieMangling {
    private let caesarCypher = CaesarCypher()

    func mangle(trie: Trie, withCaesarCypherKey key: UInt8) -> Trie {
        var trieCopy = trie

        trieCopy.label = trieCopy.label.map {
            return caesarCypher.encrypt(element: $0, key: key)
        }

        trieCopy.children = trieCopy.children.map { trie -> Trie in
            return mangle(trie: trie, withCaesarCypherKey: key)
        }

        return trieCopy
    }
}
