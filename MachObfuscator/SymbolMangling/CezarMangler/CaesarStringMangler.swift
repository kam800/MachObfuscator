import Foundation

protocol CaesarStringMangling: AnyObject {
    func mangle(_ word: String, usingCypherKey cypherKey: UInt8) -> String
}

final class CaesarStringMangler: CaesarStringMangling {
    private let caesarCypher = CaesarCypher()

    func mangle(_ word: String, usingCypherKey cypherKey: UInt8) -> String {
        if word.hasPrefix("set") {
            let startIndexShiftedByThree = word.index(word.startIndex, offsetBy: 3)...
            let wordSubstring: String = String(word[startIndexShiftedByThree])
            return "set" + mangle(wordSubstring, usingCypherKey: cypherKey)
        }

        return String(bytes: word.utf8.map { caesarCypher.cypher(element: $0, cypherKey: cypherKey) }, encoding: .utf8)!
    }
}
