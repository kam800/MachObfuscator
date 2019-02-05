protocol SymbolMangling {
    var key: String { get }

    var helpDescription: String { get }

    func mangleSymbols(_: ObfuscationSymbols) -> SymbolManglingMap
}
