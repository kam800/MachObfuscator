import Foundation

protocol TextFileSymbolListLoaderProtocol {
    func load(fromTextFile url: URL) -> ObjectSymbols
}

class TextFileSymbolListLoader: TextFileSymbolListLoaderProtocol {
    func load(fromTextFile url: URL) -> ObjectSymbols {
        do {
            LOGGER.info("Collecting symbols from text file \(url)")
            return try load(fromTextFile: url, stringWithContentsOf: String.init(contentsOf:))
        } catch {
            fatalError("Error while reading symbols from text file '\(url)': \(error)")
        }
    }

    func load(fromTextFile url: URL, stringWithContentsOf: (URL) throws -> String) throws -> ObjectSymbols {
        let contents = try stringWithContentsOf(url)
        let lines = contents.split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .uniq

        // Following lines filtering is just an optimisation, removing those filters will not affect the MachObfuscator
        // output. Why optimising? `strings` produces a lot of garbage.
        return ObjectSymbols(selectors: lines.filter { $0.couldBeSelector },
                             classNames: lines.filter { $0.couldBeClassName })
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
