import Foundation

struct Trie {
    var exportsSymbol: Bool
    var labelRange: Range<UInt64>
    var label: [UInt8]
    var children: [Trie]
}
