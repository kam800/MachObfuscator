//
//  SymbolsReporting.swift
//  MachObfuscator
//

import Foundation

protocol SymbolsReporter {
    func report(options: Options)
    func reportObjcMangling(map: SymbolManglingMap)
    func reportBlacklistedSymbols(symbolKind: String, symbols: [String])
}

extension SymbolsReporter {
    func report(options _: Options) {}
    func reportObjcMangling(map _: SymbolManglingMap) {}
    func reportBlacklistedSymbols(symbolKind _: String, symbols _: [String]) {}
}

class NoReporter: SymbolsReporter {}

class ConsoleReporter: SymbolsReporter {
    func report(options: Options) {
        // Try to make this text more readable by splitting in to multiple lines.
        // Hopefully this will not break anything, but commas in values will be replaced
        let optionsString = "\(options)".replacingOccurrences(of: ", ", with: "\n")
            .replacingOccurrences(of: "Options(", with: "", options: .anchored, range: nil)
            .dropLast(1)
        LOGGER.info("===== Obfuscator options =====\n\(optionsString)")
    }

    func reportObjcMangling(map: SymbolManglingMap) {
        LOGGER.info("===== ObjC obfuscation report =====")
        LOGGER.info("Classes mapping:\n\(map.classNames.sorted(by: <).map { "\($0) -> \($1)" }.joined(separator: "\n"))")
        LOGGER.info("Selectors mapping:\n\(map.selectors.sorted(by: <).map { "\($0) -> \($1)" }.joined(separator: "\n"))")
    }

    func reportBlacklistedSymbols(symbolKind: String, symbols: [String]) {
        if !symbols.isEmpty {
            // Very long lines cause problems with some tools
            LOGGER.info("\(symbolKind) removed by blacklist:\n\(symbols.sorted().chunked(into: 10).map { "\($0.joined(separator: ", "))" }.joined(separator: ",\n"))")
        }
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
