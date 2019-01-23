import Foundation

enum SymbolManglers {
    static let allManglers: [SymbolMangling] = [CaesarMangler(exportTrieMangler: CaesarExportTrieMangler()),
                                                RealWordsMangler(exportTrieMangler: RealWordsExportTrieMangler())]

    static func mangler(byKey key: String) -> SymbolMangling? {
        return allManglers.first { $0.key == key }
    }

    static var helpSummary: String {
        return "Available manglers by mangler_key:\n"
            + (allManglers.map { "  \($0.key) - \($0.helpDescription)" }
                .joined(separator: "\n"))
    }
}
