import Foundation

class SimpleSymbolsListLoader: ObjectSymbolsLoader {
    func load(from url: URL) throws -> ObjectSymbols {
        return try load(from: url, stringWithContentsOf: String.init(contentsOf:))
    }

    func load(from url: URL, stringWithContentsOf: (URL) throws -> String) throws -> ObjectSymbols {
        let contents = try stringWithContentsOf(url)
        let lines = contents.split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .uniq

        // Following lines filtering is just an optimisation, removing those filters will not affect the MachObfuscator
        // output. Why optimising? `strings` produces a lot of garbage.
        return ObjectSymbols(selectors: lines.filter { $0.couldBeSelector }.uniq,
                             classNames: lines.filter { $0.couldBeClassName }.uniq)
    }
}

private extension StringProtocol {
    var couldBeSelector: Bool {
        return rangeOfCharacter(from: CharacterSet.selectorForbidden) == nil
    }

    var couldBeClassName: Bool {
        return rangeOfCharacter(from: CharacterSet.classNameForbidden) == nil
    }
}

private extension CharacterSet {
    static let selectorForbidden =
        CharacterSet.whitespaces
        .union(.init(charactersIn: "!@#$%^&*()+-={}[]\"|;'\\<>?,./"))
    static let classNameForbidden =
        CharacterSet.whitespaces
        .union(.init(charactersIn: "!@#$%^&*()+-={}[]:\"|;'\\<>?,./"))
}
