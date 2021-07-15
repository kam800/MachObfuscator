import Foundation

struct Trie {
    var exportsSymbol: Bool
    // In case of Mach-O trie binary-representation, a trie node doesn't contain a label. A trie node contains an array
    // of (child-node-label, child-node-address) entries. MachObfuscator uses different, more natuaral in-memory
    // representation.
    var labelRange: Range<UInt64>
    var label: [UInt8]
    var children: [Trie]
}
