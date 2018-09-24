protocol SymbolMangling {
    static var key: String { get }
    static var helpDescription: String { get }
    init()
    func mangleSymbols(_: ObfuscationSymbols) -> SymbolManglingMap
}
