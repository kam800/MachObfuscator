protocol SymbolsSource {
    var selectors: [String] { get }
    var classNames: [String] { get }
    var cstrings: [String] { get }
    var dynamicPropertyNames: [String] { get }
    var exportedTrie: Trie? { get }
    var cpu: Mach.Cpu { get }
}
