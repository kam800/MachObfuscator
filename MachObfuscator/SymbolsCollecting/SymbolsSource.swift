protocol SymbolsSource {
    var selectors: [String] { get }
    var classNames: [String] { get }
    var methTypes: [String] { get }
    var cstrings: [String] { get }
    var exportedTrie: Trie? { get }
    var cpu: Mach.Cpu { get }
}
