import Foundation

enum SymbolManglers: String, CaseIterable {
    case caesar
    case realWords

    static var helpSummary: String {
        return "Available manglers by mangler_key:\n"
            + (SymbolManglers.allCases.map { "  \($0) - \($0.helpDescription)" }
                .joined(separator: "\n"))
    }

    static var defaultManglerKey: String {
        return SymbolManglers.realWords.rawValue
    }

    var helpDescription: String {
        switch self {
        case .realWords:
            return "replace objc symbols with random words and fill dyld info symbols with numbers"
        case .caesar:
            return "ROT13 all objc symbols and dyld info"
        }
    }

    func resolveMangler(machOViewDoom: Bool = false) -> SymbolMangling {
        switch self {
        case .realWords:
            return RealWordsMangler(exportTrieMangler: RealWordsExportTrieMangler(machOViewDoom: machOViewDoom))
        case .caesar:
            return CaesarMangler(exportTrieMangler: CaesarExportTrieMangler())
        }
    }
}
