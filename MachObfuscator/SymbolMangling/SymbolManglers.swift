import Foundation

enum SymbolManglers {
    static let allManglers: [SymbolMangling.Type] = [CezarMangler.self, RealWordsMangler.self]

    static func mangler(byKey key: String) -> SymbolMangling? {
        return allManglers.first { $0.key == key }
            .flatMap { $0.init() }
    }

    static var helpSummary: String {
        return "Available manglers by mangler_key:\n"
            + (allManglers.map { "  \($0.key) - \($0.helpDescription)" }
                .joined(separator: "\n"))
    }
}
